import 'package:shared_preferences/shared_preferences.dart';

/// Clase helper para gestionar el estado de "leído" de las notificaciones
/// usando el almacenamiento local del dispositivo.
class ReadStatusManager {
  // Clave única para guardar la lista de IDs de alertas leídas.
  static const _readAlertsKey = 'read_alerts_ids';

  /// Genera un ID único para una alerta basado en su patente y fecha.
  static String getUniqueId(String plate, DateTime? alertDate) {
    if (alertDate == null) {
      // Si no hay fecha, usamos la patente y un timestamp aleatorio para evitar colisiones
      return '$plate-${DateTime.now().millisecondsSinceEpoch}';
    }
    return '$plate-${alertDate.toIso8601String()}';
  }

  /// Carga el conjunto de IDs de alertas que ya han sido leídas.
  static Future<Set<String>> getReadAlertIds() async {
    final prefs = await SharedPreferences.getInstance();
    // Obtenemos la lista guardada, o una lista vacía si no existe.
    final List<String> readIds = prefs.getStringList(_readAlertsKey) ?? [];
    return readIds.toSet(); // La devolvemos como un Set para búsquedas rápidas.
  }

  /// Marca una alerta como leída guardando su ID único.
  static Future<void> markAlertAsRead(String alertId) async {
    final prefs = await SharedPreferences.getInstance();
    // Obtenemos la lista actual
    final List<String> readIds = prefs.getStringList(_readAlertsKey) ?? [];
    
    // Si el ID no está ya en la lista, lo añadimos.
    if (!readIds.contains(alertId)) {
      readIds.add(alertId);
      // Guardamos la lista actualizada.
      await prefs.setStringList(_readAlertsKey, readIds);
    }
  }
}
