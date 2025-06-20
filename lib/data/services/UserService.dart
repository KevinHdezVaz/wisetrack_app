import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wisetrack_app/data/models/User/UserDetail.dart';
import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

class UserService {
  static Future<UserDetail> getUserDetail() async {
    // 1. Obtener token
    final token = await TokenStorage.getToken();
    print('Obteniendo token para user/detail: $token');
    if (token == null) {
      print('Error: No hay token almacenado');
      throw Exception('Authentication required: No token found');
    }

    // 2. Configurar request
    final url = Uri.parse('${Constants.baseUrl}/user/detail');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };
    print('Configurando solicitud - URL: $url');

    try {
      // 3. Hacer la petición
      final response = await http.get(url, headers: headers);
      print('Respuesta recibida - Status Code: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      // 4. Procesar respuesta
      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          return UserDetail.fromJson(jsonResponse);
        } catch (e) {
          print('Error al parsear JSON: $e');
          throw Exception('Invalid response format: $e');
        }
      } else if (response.statusCode == 401) {
        print('Error: Sesión expirada (401)');
        throw Exception('Session expired');
      } else {
        print(
            'Error: Falló la carga de datos del usuario - ${response.statusCode}');
        throw Exception(
            'Failed to load user data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Excepción en getUserDetail: $e');
      throw Exception('Network error: $e');
    }
  }
}
