import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:http/http.dart' as http;
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart'; // Importa tus modelos de Vehicle
import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart'; // Tu clase TokenStorage

class VehicleService {
  // Helper method for authenticated requests
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenStorage.getToken();
    debugPrint('AuthService: Obteniendo token: $token'); // Log del token
    return {
      'Authorization':
          'Token $token', // Ajusta según el tipo de token (Bearer, Token, etc.)
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // 1. GET ALL VEHICLES
  static Future<List<Vehicle>> getAllVehicles() async {
    final url = Uri.parse('${Constants.baseUrl}/vehicle/get');
    debugPrint('VehicleService: Realizando GET a: $url'); // Log de la URL
    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      debugPrint(
          'VehicleService: Respuesta GET ${response.statusCode}: ${response.body}'); // Log de la respuesta

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final vehicleResponse =
            VehicleResponse.fromJson(data); // Usa VehicleResponse para parsear
        return vehicleResponse.data;
      } else {
        throw Exception(
            'Failed to load vehicles: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint(
          'VehicleService: Error en getAllVehicles: $e'); // Log del error
      throw Exception('Vehicle request failed: $e');
    }
  }

  // 2. GET VEHICLE DETAIL BY PLATE
  static Future<Vehicle> getVehicleDetail(String plate) async {
    final url = Uri.parse('${Constants.baseUrl}/vehicle/get/$plate');
    debugPrint(
        'VehicleService: Realizando GET a: $url para placa: $plate'); // Log de la URL
    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      debugPrint(
          'VehicleService: Respuesta GET ${response.statusCode}: ${response.body}'); // Log de la respuesta

      if (response.statusCode == 200) {
        return Vehicle.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load vehicle details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint(
          'VehicleService: Error en getVehicleDetail para $plate: $e'); // Log del error
      throw Exception('Vehicle detail request failed: $e');
    }
  }

  // 3. GET ALL VEHICLES POSITIONS
  static Future<List<VehiclePosition>> getVehiclesPositions(
      {String? plate}) async {
    final url = Uri.parse(
        '${Constants.baseUrl}/vehicle/get-vehicles-position${plate != null ? '/$plate' : ''}');
    debugPrint(
        'VehicleService: Realizando GET a: $url para posiciones'); // Log de la URL
    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      debugPrint(
          'VehicleService: Respuesta GET ${response.statusCode}: ${response.body}'); // Log de la respuesta

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehiclePosition.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load positions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint(
          'VehicleService: Error en getVehiclesPositions: $e'); // Log del error
      throw Exception('Position request failed: $e');
    }
  }

  // 4. GET VEHICLE HISTORY
  static Future<List<VehicleHistoryPoint>> getVehicleHistory({
    required String plate,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final formattedStart = startDate.toIso8601String();
    final formattedEnd = endDate.toIso8601String();

    final url = Uri.parse(
        '${Constants.baseUrl}/vehicle/get-history/$formattedStart/$formattedEnd');
    final body = jsonEncode({'plate': plate});
    debugPrint(
        'VehicleService: Realizando POST a: $url con body: $body'); // Log de la URL y cuerpo
    try {
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: body,
      );

      debugPrint(
          'VehicleService: Respuesta POST ${response.statusCode}: ${response.body}'); // Log de la respuesta

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehicleHistoryPoint.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint(
          'VehicleService: Error en getVehicleHistory: $e'); // Log del error
      throw Exception('History request failed: $e');
    }
  }

  // 5. SET VEHICLE TYPE
  static Future<bool> setVehicleType({
    required String plate,
    required String type,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/vehicle/set-vehicle-type');
    final body = jsonEncode({'plate': plate, 'type': type});
    debugPrint(
        'VehicleService: Realizando POST a: $url con body: $body'); // Log de la URL y cuerpo
    try {
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: body,
      );

      debugPrint(
          'VehicleService: Respuesta POST ${response.statusCode}: ${response.body}'); // Log de la respuesta

      return response.statusCode == 200;
    } catch (e) {
      debugPrint(
          'VehicleService: Error en setVehicleType: $e'); // Log del error
      throw Exception('Set type failed: $e');
    }
  }
}
