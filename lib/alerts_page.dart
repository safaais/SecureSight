import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'alert_details_page.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  Color _getRiskColor(String riskLevel, bool isResolved) {
    if (isResolved) return Colors.green;
    switch (riskLevel) {
      case 'high':
        return Colors.red;
      case 'mid':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No alerts found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final alert = docs[index].data() as Map<String, dynamic>;
              final isResolved = alert['status'] == 'resolved';
              final riskLevel = alert['risk_level'] ?? 'low';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Icon(Icons.warning, color: _getRiskColor(riskLevel, isResolved)),
                  title: Text(alert['title'] ?? 'Alert'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert['created_at'] ?? ''),
                      const SizedBox(height: 4),
                      Text(
                        'Risk: ${riskLevel.toUpperCase()}',
                        style: TextStyle(
                          color: _getRiskColor(riskLevel, isResolved),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlertDetailsPage(alert: alert),
                      ),
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
