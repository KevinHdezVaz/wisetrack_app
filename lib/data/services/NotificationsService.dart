// lib/data/services/NotificationService.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wisetrack_app/data/models/alert/NotificationPermissions.dart';
 import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

class NotificationService {

    static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
 
  /// Obtiene los permisos de notificación del usuario con logging detallado
  static Future<NotificationPermissions> getNotificationPermissions() async {
    final url = Uri.parse('${Constants.baseUrl}/user/get-notifications-permission');
    
    debugPrint('[NotificationService] 🔄 Iniciando solicitud GET a: $url');

    try {
      // 1. Obtener headers
      debugPrint('[NotificationService] Obteniendo headers de autenticación...');
      final headers = await _getAuthHeaders();
      
      // 2. Loggear headers antes de enviar
      debugPrint('[NotificationService] Headers a enviar:');
      headers.forEach((key, value) {
        debugPrint('  $key: ${key == 'Authorization' ? 'Bearer ***' : value}');
      });

      // 3. Realizar la petición
      debugPrint('[NotificationService] Enviando solicitud GET...');
      final response = await http.get(
        url,
        headers: headers,
      );

      // 4. Loggear respuesta cruda
      debugPrint('[NotificationService] 🔵 Respuesta recibida:');
      debugPrint('  Status Code: ${response.statusCode}');
      debugPrint('  Headers: ${response.headers}');
      debugPrint('  Body: ${response.body}');

      // 5. Procesar respuesta
      if (response.statusCode == 200) {
        try {
          final String responseBody = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> data = jsonDecode(responseBody);
          debugPrint('[NotificationService] ✅ Datos parseados correctamente');
          return NotificationPermissionsResponse.fromJson(data).data;
        } catch (e) {
          debugPrint('[NotificationService] ❌ Error al parsear respuesta: $e');
          throw Exception('Error al procesar la respuesta del servidor');
        }
      } else if (response.statusCode == 401) {
        debugPrint('[NotificationService] ❌ Error 401 - Detalle completo:');
        debugPrint('  URL: $url');
        debugPrint('  Headers enviados: $headers');
        debugPrint('  Body recibido: ${response.body}');
        throw Exception('Sesión expirada. Por favor vuelve a iniciar sesión');
      } else {
        debugPrint('[NotificationService] ❌ Error ${response.statusCode}');
        throw Exception('Error al obtener permisos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[NotificationService] ❌ Error en getNotificationPermissions: $e');
      rethrow;
    }
  }


static Future<bool> updateSingleNotificationPermission({
  required String name,
  required bool value,
}) async {
  final url = Uri.parse('${Constants.baseUrl}/user/change-notification-permissions');
  
  debugPrint('[NotificationService] 🔄 Iniciando solicitud POST individual a: $url');

  try {
    // 1. Preparar payload específico
    final payload = {
      'name': name,
      'value': value,
    };

    debugPrint('[NotificationService] Payload individual a enviar:');
    debugPrint(jsonEncode(payload));

    // 2. Obtener headers
    final headers = await _getAuthHeaders();

    // 3. Enviar solicitud
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    debugPrint('[NotificationService] 🔵 Respuesta recibida (individual):');
    debugPrint('  Status Code: ${response.statusCode}');
    debugPrint('  Body: ${response.body}');

    if (response.statusCode == 200) {
      debugPrint('[NotificationService] ✅ Permiso individual actualizado correctamente');
      return true;
    } else {
      debugPrint('[NotificationService] ❌ Error ${response.statusCode} en actualización individual');
      debugPrint('  Detalle: ${response.body}');
      throw Exception('Error al actualizar permiso individual: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('[NotificationService] ❌ Error en updateSingleNotificationPermission: $e');
    rethrow;
  }
}

 
}