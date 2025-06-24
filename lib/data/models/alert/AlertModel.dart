// lib/data/models/alerts/AlertModel.dart

import 'dart:convert';

/// Modelo para la respuesta completa de la API, que contiene una lista de alertas.
class AlertsResponse {
  final List<Alertas> data;

  AlertsResponse({required this.data});

  factory AlertsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return AlertsResponse(
      data: list.map((item) => Alertas.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

/// Modelo para una única alerta.
/// ESTA ES LA VERSIÓN COMPLETA QUE INCLUYE 'name' Y 'alertDate'.
class Alertas {
  final String name;
  final String plate;
  final DateTime? alertDate;
  final double? speed;
  final double? latitude;
  final double? longitude;
  final String driverName;
  final String? geofenceName;
  final int status;
  final AlertType alertType;
  final AlertVehicle vehicle;

  Alertas({
    required this.name,
    required this.plate,
    this.alertDate,
    this.speed,
    this.latitude,
    this.longitude,
    required this.driverName,
    this.geofenceName,
    required this.status,
    required this.alertType,
    required this.vehicle,
  });

  factory Alertas.fromJson(Map<String, dynamic> json) {
    // Helper para parsear números de forma segura
    double? safeParseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Helper para parsear fechas de forma segura
    DateTime? safeParseDateTime(dynamic value) {
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return Alertas(
      name: json['name'] as String? ?? 'Alerta desconocida',
      plate: json['plate'] as String? ?? '',
      alertDate: safeParseDateTime(json['alert_date']),
      speed: (json['speed'] as num?)?.toDouble(),
      latitude: safeParseDouble(json['latitude']),
      longitude: safeParseDouble(json['longitude']),
      driverName: json['driver_name'] as String? ?? 'Sin conductor',
      geofenceName: json['geofence_name'] as String?,
      status: json['status'] as int? ?? 0,
      alertType: AlertType.fromJson(json['alert_type'] as Map<String, dynamic>? ?? {}),
      vehicle: AlertVehicle.fromJson(json['vehicle'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Modelo para el objeto anidado 'alert_type'.
class AlertType {
  final String name;

  AlertType({required this.name});

  factory AlertType.fromJson(Map<String, dynamic> json) {
    return AlertType(
      name: json['name'] as String? ?? '',
    );
  }
}

/// Modelo para el objeto anidado 'vehicle'.
class AlertVehicle {
  final String plate;

  AlertVehicle({required this.plate});

  factory AlertVehicle.fromJson(Map<String, dynamic> json) {
    return AlertVehicle(
      plate: json['plate'] as String? ?? '',
    );
  }
}