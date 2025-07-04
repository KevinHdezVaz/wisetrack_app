// lib/data/models/vehicles/Vehicle.dart

import 'dart:convert';
import 'package:flutter/material.dart'; // Necesario para IconData

 class VehicleResponse {
  final List<Vehicle> data;

  VehicleResponse({required this.data});

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List<dynamic>?;
    List<Vehicle> vehicleList = [];
    if (list != null) {
      vehicleList = list
          .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return VehicleResponse(data: vehicleList);
  }
}

class VehicleTypesResponse {
  final List<VehicleType> data;

  VehicleTypesResponse({required this.data});

  factory VehicleTypesResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List<dynamic>? ?? [];
    return VehicleTypesResponse(
      data: list.map((item) => VehicleType.fromJson(item)).toList(),
    );
  }
}

class VehicleType {
  final int id;
  final String name;

  VehicleType({required this.id, required this.name});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Desconocido',
    );
  }
}
 
 

class Vehicle {
  final String plate;
  final int statusDevice; // 1 = activo (GPS), 0 = inactivo
  final int statusVehicle; // 1 = activo (ubicación), 0 = inactivo (motor)
  final int vehicleType; // El ID numérico del tipo de vehículo
  final DateTime? lastReport;
  final List<dynamic> permission;

  Vehicle({
    required this.plate,
    required this.statusDevice,
    required this.statusVehicle,
    required this.vehicleType,
    this.lastReport,
    required this.permission,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      plate: json['plate'] as String? ?? '',
      statusDevice: json['status_device'] as int? ?? 0,
      statusVehicle: json['status_vehicle'] as int? ?? 0,
      vehicleType: json['vehicle_type'] as int? ?? 0,
      lastReport: (json['last_report'] is String &&
              (json['last_report'] as String).isNotEmpty)
          ? DateTime.tryParse(json['last_report'])
          : null,
      permission: (json['permission'] as List<dynamic>?) ?? [],
    );
  }
}

enum VehicleTypeEnum {
  lightVehicle, // 1: Coche pequeño, Liviano (asumido del PDF y JSON)
  truck, // 2: Camión (asumido del JSON)
  bus, // 163: Bus (asumido del JSON)
  tracto, // Tracto (del PDF)
  ramplaSeca, // Rampla Seca (del PDF)
  ramplaFria, // Rampla Fría (del PDF)
  camion3_4, // Camión 3/4 (del PDF)
  camaBaja, // Cama Baja (del PDF)
  cistern, // Cisterna (del PDF)
  tolva, // Tolva (del PDF)
  caex, // Caex (del PDF)
  forklift, // Grúa Horquilla (del PDF)
  crane, // Pluma, Grúa Vehicular (combinado por icono similar)
  fireTruck, // Carro Bomba (del PDF)
  van, // Furgón (del PDF)
  excavator, // Retro-excavadora (del PDF)
  loader, // Cargador Frontal (del PDF)
  other, // Otro (del PDF) - para cualquier tipo no mapeado
  unknown, // Fallback para tipos no reconocidos
}

extension VehicleTypeIntExtension on int {
  // Renombrado para mayor claridad
  VehicleTypeEnum toVehicleTypeEnum() {
    switch (this) {
      case 1:
        return VehicleTypeEnum.lightVehicle;
      case 2:
        return VehicleTypeEnum.truck;
      case 163:
        return VehicleTypeEnum.bus;
      // --- Añade aquí el mapeo para otros 'vehicle_type' que recibas de tu API ---
      // Ejemplo (necesitarás los IDs reales de tu backend):
      // case 3: return VehicleTypeEnum.tracto;
      // case 4: return VehicleTypeEnum.ramplaSeca;
      // case 5: return VehicleTypeEnum.ramplaFria;
      // case 6: return VehicleTypeEnum.camion3_4;
      // case 7: return VehicleTypeEnum.camaBaja;
      // case 8: return VehicleTypeEnum.cistern;
      // case 9: return VehicleTypeEnum.tolva;
      // case 10: return VehicleTypeEnum.caex;
      // case 11: return VehicleTypeEnum.forklift;
      // case 12: return VehicleTypeEnum.crane;
      // case 13: return VehicleTypeEnum.fireTruck;
      // case 14: return VehicleTypeEnum.van;
      // case 15: return VehicleTypeEnum.excavator;
      // case 16: return VehicleTypeEnum.loader;
      // case 17: return VehicleTypeEnum.other;

      default:
        return VehicleTypeEnum.unknown; // Tipo desconocido
    }
  }
}

 extension VehicleTypeEnumExtension on VehicleTypeEnum {
  IconData get iconData {
    switch (this) {
      case VehicleTypeEnum.lightVehicle:
        return Icons.directions_car;
      case VehicleTypeEnum.bus:
        return Icons.directions_bus;
      case VehicleTypeEnum.truck:
        return Icons.local_shipping;
      case VehicleTypeEnum.tracto:
        return Icons.airport_shuttle;
      case VehicleTypeEnum.ramplaSeca:
        return Icons.fire_truck;
      case VehicleTypeEnum.ramplaFria:
        return Icons.airport_shuttle;
      case VehicleTypeEnum.camion3_4:
        return Icons.local_shipping;
      case VehicleTypeEnum.camaBaja:
        return Icons.airport_shuttle;
      case VehicleTypeEnum.cistern:
        return Icons.local_shipping;
      case VehicleTypeEnum.tolva:
        return Icons.inventory;
      case VehicleTypeEnum.caex:
        return Icons.construction;
      case VehicleTypeEnum.forklift:
        return Icons.forklift;
      case VehicleTypeEnum.crane:
        return Icons.cable;
      case VehicleTypeEnum.fireTruck:
        return Icons.fire_truck;
      case VehicleTypeEnum.van:
        return Icons.airport_shuttle;
      case VehicleTypeEnum.excavator:
        return Icons.construction;
      case VehicleTypeEnum.loader:
        return Icons.construction;
      case VehicleTypeEnum.other:
        return Icons.directions_car;
      case VehicleTypeEnum.unknown:
      default:
        return Icons.help_outline;
    }
  }

  // Opcional: Getter para obtener un IconData de Material si prefieres eso
  IconData get defaultIconData {
    switch (this) {
      case VehicleTypeEnum.lightVehicle:
        return Icons.directions_car;
      case VehicleTypeEnum.truck:
        return Icons.local_shipping;
      case VehicleTypeEnum.bus:
        return Icons.directions_bus;
      case VehicleTypeEnum.cistern:
        return Icons.opacity;
      case VehicleTypeEnum.forklift:
        return Icons.agriculture; // Usando un icono de maquinaria pesada
      case VehicleTypeEnum.crane:
        return Icons.construction; // Icono de construcción
      case VehicleTypeEnum.fireTruck:
        return Icons.fire_truck;
      case VehicleTypeEnum.van:
        return Icons.airport_shuttle;
      case VehicleTypeEnum.excavator:
        return Icons.construction;
      case VehicleTypeEnum.loader:
        return Icons.construction;
      default:
        return Icons.help_outline;
    }
  }
}

// Modelos para posición e historial, se mantienen sin cambios
class VehiclePosition {
  final String plate;
  final double lat;
  final double lng;
  final DateTime timestamp;

  VehiclePosition({
    required this.plate,
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  factory VehiclePosition.fromJson(Map<String, dynamic> json) {
    return VehiclePosition(
      plate: json['plate'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class VehicleHistoryPoint {
  final double lat;
  final double lng;
  final DateTime timestamp;
  final int? speed;

  VehicleHistoryPoint({
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.speed,
  });

  factory VehicleHistoryPoint.fromJson(Map<String, dynamic> json) {
    return VehicleHistoryPoint(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      speed: json['speed'] as int?,
    );
  }
}
