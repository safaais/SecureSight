import 'dart:convert';

class AlertStore {
  static List<Map<String, dynamic>> alerts = [];

  static void addAlert(Map<String, dynamic> alert) {
    alerts.insert(0, alert);
  }

  static List<Map<String, dynamic>> getAlerts() {
    return alerts;
  }

  static String encodePayload(Map<String, dynamic> alert) {
    return jsonEncode(alert);
  }

  static Map<String, dynamic> decodePayload(String payload) {
    return jsonDecode(payload);
  }
}
