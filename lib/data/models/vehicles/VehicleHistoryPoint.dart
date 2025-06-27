import 'dart:convert';

/// Modelo para la respuesta completa de la API del historial.
class HistoryResponse {
  final List<HistoryPoint> data;

  HistoryResponse({
    required this.data,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    // La respuesta es una lista anidada dentro de la clave "data"
    final list = json['data'] as List<dynamic>? ?? [];
    return HistoryResponse(
      data: list.map((item) => HistoryPoint.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

/// Modelo para un único punto en el historial de un vehículo.
/// Representa todos los campos que devuelve el endpoint de historial.
class HistoryPoint {
  final String plate;
  final DateTime? timestamp;
  final double latitude;
  final double longitude;
  final double speed;
  final int direction;
  final String status;
  final double? analogSensor1;
  final double? analogSensor2;
  final double? analogSensor3;
  final bool ignitionStatus;
  final bool digitalSensor1;
  final bool digitalSensor2;
  final bool digitalSensor3;
  final bool digitalSensor4;
  final bool digitalSensor5;
  final bool digitalSensor6;
  final int? odometer;

  HistoryPoint({
    required this.plate,
    this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.direction,
    required this.status,
    this.analogSensor1,
    this.analogSensor2,
    this.analogSensor3,
    required this.ignitionStatus,
    required this.digitalSensor1,
    required this.digitalSensor2,
    required this.digitalSensor3,
    required this.digitalSensor4,
    required this.digitalSensor5,
    required this.digitalSensor6,
    this.odometer,
  });

  factory HistoryPoint.fromJson(Map<String, dynamic> json) {
    // Helper para parsear números de forma segura (String -> double?)
    double? safeParseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return HistoryPoint(
      plate: json['mov_codigo'] as String? ?? '',
      timestamp: (json['mopo_fechahora'] is String)
          ? DateTime.tryParse(json['mopo_fechahora'])
          : null,
      
      latitude: safeParseDouble(json['mopo_lat']) ?? 0.0,
      longitude: safeParseDouble(json['mopo_lon']) ?? 0.0,
      speed: (json['mopo_vel'] as num?)?.toDouble() ?? 0.0,
      direction: json['mopo_dir'] as int? ?? 0,
      status: json['mopo_estado'] as String? ?? '',
      analogSensor1: safeParseDouble(json['mopo_sensora1']),
      analogSensor2: safeParseDouble(json['mopo_sensora2']),
      analogSensor3: safeParseDouble(json['mopo_sensora3']),
      ignitionStatus: json['mopo_estado_ignicion'] as bool? ?? false,
      digitalSensor1: json['mopo_sensord1'] as bool? ?? false,
      digitalSensor2: json['mopo_sensord2'] as bool? ?? false,
      digitalSensor3: json['mopo_sensord3'] as bool? ?? false,
      digitalSensor4: json['mopo_sensord4'] as bool? ?? false,
      digitalSensor5: json['mopo_sensord5'] as bool? ?? false,
      digitalSensor6: json['mopo_sensord6'] as bool? ?? false,
      odometer: json['odometro'] as int?,
      // Puedes añadir aquí el resto de los campos 'null' si los necesitas
    );
  }
}