import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wisetrack_app/data/models/Alert.dart';
import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

class AlertService {
  // Obtener todas las alertas
  static Future<List<Alert>> getAlerts() async {
    final url = Uri.parse('${Constants.baseUrl}/alert/get');
    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Alert.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar alertas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Headers comunes
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };
  }
}
