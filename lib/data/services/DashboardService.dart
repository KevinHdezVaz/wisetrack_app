import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wisetrack_app/data/models/dashboard/DashboardData.dart'; // Importa el nuevo modelo
import 'package:wisetrack_app/data/models/dashboard/DashboardDetailModel.dart';
import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

/// Servicio para obtener los datos consolidados del Dashboard.
class DashboardService {

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

   /// Obtiene los datos detallados para una categoría específica del dashboard.
  static Future<DashboardDetailData> getDashboardDetailData({
    required int rangeInHours,
    required String dataType, // "d_vehicles_type", "d_vehicles_status", o "d_alert_plan"
  }) async {
    
    final now = DateTime.now();
    final formattedEndDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

    final url = Uri.parse(
        '${Constants.baseUrl}/vehicle/get-dashboard-data/$formattedEndDate/$rangeInHours/$dataType');
    
    debugPrint('DashboardService: Realizando GET a: $url');

    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      debugPrint('DashboardService: Respuesta GET ${response.statusCode}');

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        return DashboardDetailData.fromJson(jsonDecode(responseBody));
      } else {
        throw Exception('Fallo al cargar los datos de detalle: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DashboardService: Error en getDashboardDetailData: $e');
      throw Exception('La petición de detalle del dashboard falló: $e');
    }
  }
  

  /// Obtiene los datos del dashboard para un rango de horas específico.
  static Future<DashboardData> getDashboardData({required int rangeInHours}) async {
    // La URL incluye el rango de horas como un parámetro de ruta.
    final url = Uri.parse('${Constants.baseUrl}/vehicle/get-dashboard-data/$rangeInHours');
    
    debugPrint('DashboardService: Realizando GET a: $url');

    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      debugPrint('DashboardService: Respuesta GET ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decodificamos como UTF-8 para manejar acentos y caracteres especiales.
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(responseBody);
        
        // Usamos el factory del modelo para parsear la respuesta.
        return DashboardDataResponse.fromJson(jsonData).data;
      } else {
        throw Exception('Fallo al cargar los datos del dashboard: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('DashboardService: Error en getDashboardData: $e');
      throw Exception('La petición de datos del dashboard falló: $e');
    }
  }
}
