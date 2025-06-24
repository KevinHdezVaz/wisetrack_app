// lib/data/services/AlertService.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wisetrack_app/data/models/alert/AlertModel.dart';
 import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

class AlertService {
  
  // Helper para obtener las cabeceras de autenticación.
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Obtiene una lista de todas las alertas.
  static Future<List<Alertas>> getAlerts() async {
    // IMPORTANTE: Debes confirmar la URL correcta para obtener las alertas.
    // Estoy usando '/alerts/get' como un ejemplo lógico.
    final url = Uri.parse('${Constants.baseUrl}/alert/get'); 
    
    debugPrint('AlertService: Realizando GET a: $url');

    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      debugPrint('AlertService: Respuesta GET ${response.statusCode}: ${response.body}');

     if (response.statusCode == 200) {
  // CORRECCIÓN: Decodificamos los bytes de la respuesta como UTF-8
  final String responseBody = utf8.decode(response.bodyBytes);
  final Map<String, dynamic> data = jsonDecode(responseBody);
  
  final alertsResponse = AlertsResponse.fromJson(data);
  return alertsResponse.data;
} else {
        throw Exception('Failed to load alerts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('AlertService: Error en getAlerts: $e');
      throw Exception('Alerts request failed: $e');
    }
  }
  
  // Aquí podrías añadir en el futuro otros métodos, como por ejemplo:
  // - getAlertsByPlate(String plate)
  // - markAlertAsRead(int alertId)
}