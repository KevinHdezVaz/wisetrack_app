// lib/data/models/vehicles/VehiclePositionModel.dart

import 'dart:convert';

// Función helper para decodificar el JSON de forma sencilla
VehiclePositionResponse vehiclePositionResponseFromJson(String str) =>
    VehiclePositionResponse.fromJson(json.decode(str));

/// Modelo para la respuesta completa de la API, que contiene una lista de posiciones.
class VehiclePositionResponse {
  final List<VehicleCurrentPosition> data;

  VehiclePositionResponse({
    required this.data,
  });

  factory VehiclePositionResponse.fromJson(Map<String, dynamic> json) {
    // Verificamos si 'data' es una lista, si no, creamos una lista vacía.
    final list = json['data'] as List<dynamic>?;
    
    return VehiclePositionResponse(
      data: list != null
          ? List<VehicleCurrentPosition>.from(list.map((item) =>
              VehicleCurrentPosition.fromJson(item as Map<String, dynamic>)))
          : [], // Si 'data' no existe o es nulo, devuelve una lista vacía
    );
  }
}

/// Modelo para un único punto de posición de un vehículo.
class VehicleCurrentPosition {
  final double latitude;
  final double longitude;
  final double speed;
  final int direction;
  final bool ignitionStatus;
  final String vehiclePlate; // Renombrado de 'vehicle' a 'vehiclePlate' para mayor claridad

  VehicleCurrentPosition({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.direction,
    required this.ignitionStatus,
    required this.vehiclePlate,
  });

  factory VehicleCurrentPosition.fromJson(Map<String, dynamic> json) {
    return VehicleCurrentPosition(
      // Parseamos el String a double de forma segura, con un valor por defecto.
      latitude: double.tryParse(json['latitude'] as String? ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude'] as String? ?? '0.0') ?? 0.0,

      // Parseamos la velocidad como número y lo convertimos a double.
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,

      // Parseamos los demás campos con valores por defecto en caso de ser nulos.
      direction: json['direction'] as int? ?? 0,
      ignitionStatus: json['ignition_status'] as bool? ?? false,
      vehiclePlate: json['vehicle'] as String? ?? '',
    );
  }
}