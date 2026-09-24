import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class RecordedFootagePage extends StatelessWidget {
  const RecordedFootagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("recorded_footage".tr()),
        backgroundColor: const Color(0xFFF2F2F2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .where('description', isNotEqualTo: null)
            .where('videoUrl', isGreaterThan: '') // Ensures video exists
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("no_recorded_footage".tr()));
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final doc = reports[index];
              final data = doc.data() as Map<String, dynamic>;

              final place = data['place'] ?? '';
              final date = data['date'] ?? '';
              final videoUrl = data['videoUrl'] ?? '';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: const Icon(Icons.videocam, color: Colors.deepOrange),
                  title: Text(place),
                  subtitle: Text("${"recorded_on".tr()}: $date"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to AlertDetailsPage with full document data
                    Navigator.pushNamed(
                      context,
                      '/alertDetails', // Make sure this route is defined in your MaterialApp
                      arguments: doc, // Pass the whole Firestore document
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}