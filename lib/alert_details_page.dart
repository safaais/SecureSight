
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertDetailsPage extends StatelessWidget {
  final Map<String, dynamic> alert;

  const AlertDetailsPage({super.key, required this.alert});

  Future<void> _resolveAlert(BuildContext context) async {
    await http.post(
      Uri.parse('http://10.0.2.2:8000/resolve_alert'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": alert['title']}),
    );
    Navigator.pop(context);
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
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
    final String title = alert['title'] ?? 'Unknown Alert';
    final String date = alert['date'] ?? '20-5-2025';
    final String status = alert['status'] ?? 'unresolved';
    final bool isResolved = status == 'resolved';
    final String location = alert['location'] ?? 'Unknown Location';
    final String riskLevel = alert['risk_level']?.toUpperCase() ?? 'LOW';
    final String description = alert['description'] ?? 'A person has fallen - immediate assistance may be needed.';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Alert Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Video Placeholder
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, size: 50, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),

            // Title and Date
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Dynamic Alert Details
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location: $location",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Risk Level: $riskLevel",
                      style: TextStyle(
                          color: _getRiskColor(riskLevel),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("description: $description",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text("Action Required:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    "1- Check sitiuation.\n"
                    "2- Do not forget to write a report if needed.\n"
                    ,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Accept or Resolved UI
            isResolved
                ? Column(
                    children: const [
                      Text(
                        "You accepted this alert",
                        style: TextStyle(color: Colors.green, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.grey),
                          fixedSize: MaterialStatePropertyAll(Size(200, 45)),
                        ),
                        child: Text("Accepted"),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () => _resolveAlert(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      fixedSize: const Size(200, 45),
                    ),
                    child: const Text("Accept", style: TextStyle(fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}
