import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wisetrack_app/data/models/User/UserDetail.dart';
import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

class UserService {
  static Future<UserDetail> getUserDetail() async {
    // 1. Obtener token
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Authentication required');

    // 2. Configurar request
    final url = Uri.parse('${Constants.baseUrl}/user/detail');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    try {
      // 3. Hacer la petición
      final response = await http.get(url, headers: headers);

      // 4. Procesar respuesta
      if (response.statusCode == 200) {
        return UserDetail.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
