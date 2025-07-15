import 'package:flutter/foundation.dart';
import 'package:wisetrack_app/data/services/NotificationsService.dart';
 import 'package:wisetrack_app/utils/ReadStatusManager.dart';

/// Gestiona el estado del contador de notificaciones no leídas.
class NotificationCountService {
  
  // Notificador que emitirá los cambios del contador. Es estático para que sea accesible globalmente.
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  /// Actualiza el contador obteniendo todos los datos necesarios.
  /// Llama a este método al iniciar la app o al volver desde el background.
  static Future<void> updateCount() async {
    try {
      // 1. Obtiene todas las notificaciones de la API.
      final notificationData = await NotificationService.getNotifications();
      final allNotifications = [
        ...notificationData.todayNotifications,
        ...notificationData.previousNotifications
      ];

      // 2. Obtiene los IDs de las notificaciones que ya leímos localmente.
      final readIds = await ReadStatusManager.getReadNotificationIds();

      // 3. Calcula cuántas notificaciones de la API no están en nuestra lista de leídas.
      int unreadCount = 0;
      for (var notification in allNotifications) {
        if (!readIds.contains(notification.id)) {
          unreadCount++;
        }
      }

      // 4. Actualiza el valor del notificador.
      unreadCountNotifier.value = unreadCount;

    } catch (e) {
      debugPrint("Error al actualizar el contador de notificaciones: $e");
      // Opcional: podrías decidir poner el contador a 0 en caso de error.
      // unreadCountNotifier.value = 0;
    }
  }

  /// Decrementa el contador en uno.
  /// Úsalo para una actualización instantánea cuando el usuario lee una notificación.
  static void decrementCount() {
    if (unreadCountNotifier.value > 0) {
      unreadCountNotifier.value--;
    }
  }
}