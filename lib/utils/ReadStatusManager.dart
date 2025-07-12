import 'package:shared_preferences/shared_preferences.dart';

class ReadStatusManager {
  static const _readAlertsKey = 'read_alerts_ids';
  static String getUniqueId(String plate, DateTime? alertDate) {
    if (alertDate == null) {
      return '$plate-${DateTime.now().millisecondsSinceEpoch}';
    }
    return '$plate-${alertDate.toIso8601String()}';
  }

  static Future<Set<String>> getReadAlertIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> readIds = prefs.getStringList(_readAlertsKey) ?? [];
    return readIds.toSet(); // La devolvemos como un Set para búsquedas rápidas.
  }

  static Future<void> markAlertAsRead(String alertId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> readIds = prefs.getStringList(_readAlertsKey) ?? [];
    if (!readIds.contains(alertId)) {
      readIds.add(alertId);
      await prefs.setStringList(_readAlertsKey, readIds);
    }
  }
}
