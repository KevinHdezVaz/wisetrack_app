import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart'; // Importa tus modelos de Vehicle
import 'package:wisetrack_app/data/models/vehicles/VehicleDetail.dart';
import 'package:wisetrack_app/data/models/vehicles/VehicleHistoryPoint.dart';
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
   static Future<VehicleDetail> getVehicleDetail(String plate) async {
    final url = Uri.parse('${Constants.baseUrl}/vehicle/get/$plate');
    debugPrint('VehicleService: Realizando GET a: $url para placa: $plate');
    
    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      debugPrint('VehicleService: Respuesta GET ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        // Ahora es más simple, solo pasamos el JSON al nuevo modelo.
        return VehicleDetail.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load vehicle details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VehicleService: Error en getVehicleDetail para $plate: $e');
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

  // 4. GET VEHICLE HISTORY (CORREGIDO PARA USAR GET)
  static Future<List<HistoryPoint>> getVehicleHistory({
    required String plate,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final formattedStart = DateFormat("yyyy-MM-dd").format(startDate);
    final formattedEnd = DateFormat("yyyy-MM-dd").format(endDate);
    
    // CAMBIO 1: Construimos la URL base sin los parámetros de consulta
    final baseUrl = '${Constants.baseUrl}/vehicle/get-history/$formattedStart/$formattedEnd';

    // CAMBIO 2: Creamos un objeto Uri y le añadimos los parámetros de consulta
    // de forma segura. Esto se encarga de formatear la URL correctamente
    // como: ...?plate=RDXH27
    final url = Uri.parse(baseUrl).replace(
      queryParameters: {'plate': plate},
    );
 

    debugPrint('VehicleService: Realizando GET a: $url');
    
    try {
      // CAMBIO 4: La llamada ahora es http.get() y no tiene 'body'.
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      debugPrint('VehicleService: Respuesta GET ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        // La lógica para procesar la respuesta es la misma.
        final historyResponse = HistoryResponse.fromJson(jsonDecode(response.body));
        return historyResponse.data;
      } else {
        throw Exception('Failed to load history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VehicleService: Error en getVehicleHistory: $e');
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


static Future<List<VehicleType>> getVehicleTypes() async {
  final url = Uri.parse('${Constants.baseUrl}/vehicle/get-types'); // Asumiendo que esta es la ruta
  debugPrint('VehicleService: Realizando GET a: $url');
  
  try {
    final headers = await _getAuthHeaders();
    headers['Accept-Charset'] = 'utf-8'; // Agregar header para soporte UTF-8
    
    final response = await http.get(
      url,
      headers: headers,
    );

    debugPrint('VehicleService: Respuesta GET ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes)); // Decodificar como UTF-8
      final typesResponse = VehicleTypesResponse.fromJson(data);
      return typesResponse.data;
    } else {
      throw Exception('Failed to load vehicle types: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    debugPrint('VehicleService: Error en getVehicleTypes: $e');
    throw Exception('Vehicle types request failed: $e');
  }
}


 
  /// 5. Obtiene el historial de un vehículo usando una fecha de fin y un rango.
  /// Envía una petición GET con un BODY (comportamiento no estándar de la API).
  static Future<List<HistoryPoint>> getVehicleHistoryByRange({
    required String plate,
    required DateTime endDate,
    required int rangeInHours,
  }) async {
    final formattedEndDate = DateFormat('yyyy-MM-dd HH:mm').format(endDate);
    final url = Uri.parse('${Constants.baseUrl}/vehicle/get-history/$formattedEndDate/$rangeInHours');

    debugPrint('VehicleService: Realizando GET a: $url');
    
    try {
      // Se construye la petición manualmente para poder enviar un GET con body.
      final request = http.Request('GET', url)
        ..headers.addAll(await _getAuthHeaders())
        ..body = jsonEncode({'plate': plate});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('VehicleService: Respuesta GET ${response.statusCode}');

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final historyResponse = HistoryResponse.fromJson(jsonDecode(responseBody));
        return historyResponse.data;
      } else {
        throw Exception('Fallo al cargar historial por rango: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VehicleService: Error en getVehicleHistoryByRange: $e');
      throw Exception('La petición de historial por rango falló: $e');
    }
  }


}
