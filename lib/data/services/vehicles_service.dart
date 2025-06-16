import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart';
import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

class VehicleService {
  // Helper method for authenticated requests
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };
  }

  // 1. GET ALL VEHICLES
  static Future<List<Vehicle>> getAllVehicles() async {
    final url = Uri.parse('${Constants.baseUrl}/vehicle/get');
    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Vehicle request failed: $e');
    }
  }

  // 2. GET VEHICLE DETAIL BY PLATE
  static Future<Vehicle> getVehicleDetail(String plate) async {
    final url = Uri.parse('${Constants.baseUrl}/vehicle/get/$plate');
    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return Vehicle.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load vehicle details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Vehicle detail request failed: $e');
    }
  }

  // 3. GET ALL VEHICLES POSITIONS
  static Future<List<VehiclePosition>> getVehiclesPositions(
      {String? plate}) async {
    final url = Uri.parse(
        '${Constants.baseUrl}/vehicle/get-vehicles-position${plate != null ? '/$plate' : ''}');
    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehiclePosition.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load positions: ${response.statusCode}');
      }
    } catch (e) {
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

    try {
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode({'plate': plate}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehicleHistoryPoint.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('History request failed: $e');
    }
  }

  // 5. SET VEHICLE TYPE
  static Future<bool> setVehicleType({
    required String plate,
    required String type,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/vehicle/set-vehicle-type');
    try {
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode({'plate': plate, 'type': type}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Set type failed: $e');
    }
  }
}
