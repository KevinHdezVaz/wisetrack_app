// lib/data/models/vehicles/Vehicle.dart

import 'dart:convert';
import 'package:flutter/material.dart'; // Necesario para IconData

// Modelo principal para la respuesta de la API que contiene una lista de vehículos
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

// Modelo para un solo vehículo
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

// Enumeración que representa los tipos de vehículos con nombres descriptivos
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

// <--- CAMBIO CLAVE AQUÍ: toVehicleTypeEnum() sigue siendo una extensión en int ---
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

// <--- NUEVA EXTENSIÓN: imageAssetPath y defaultIconData son ahora métodos de VehicleTypeEnum ---
extension VehicleTypeEnumExtension on VehicleTypeEnum {
  String get imageAssetPath {
    switch (this) {
      // Usamos 'this' porque es una extensión de VehicleTypeEnum
      case VehicleTypeEnum.lightVehicle:
        return 'assets/icons/vehicle_light.png';
      case VehicleTypeEnum.bus:
        return 'assets/icons/vehicle_bus.png';
      case VehicleTypeEnum.truck:
        return 'assets/icons/vehicle_truck.png';
      case VehicleTypeEnum.tracto:
        return 'assets/icons/vehicle_tracto.png';
      case VehicleTypeEnum.ramplaSeca:
        return 'assets/icons/vehicle_rampla_seca.png';
      case VehicleTypeEnum.ramplaFria:
        return 'assets/icons/vehicle_rampla_fria.png';
      case VehicleTypeEnum.camion3_4:
        return 'assets/icons/vehicle_camion_3_4.png';
      case VehicleTypeEnum.camaBaja:
        return 'assets/icons/vehicle_cama_baja.png';
      case VehicleTypeEnum.cistern:
        return 'assets/icons/vehicle_cisterna.png';
      case VehicleTypeEnum.tolva:
        return 'assets/icons/vehicle_tolva.png';
      case VehicleTypeEnum.caex:
        return 'assets/icons/vehicle_caex.png';
      case VehicleTypeEnum.forklift:
        return 'assets/icons/vehicle_forklift.png';
      case VehicleTypeEnum.crane:
        return 'assets/icons/vehicle_crane.png';
      case VehicleTypeEnum.fireTruck:
        return 'assets/icons/vehicle_fire_truck.png';
      case VehicleTypeEnum.van:
        return 'assets/icons/vehicle_van.png';
      case VehicleTypeEnum.excavator:
        return 'assets/icons/vehicle_excavator.png';
      case VehicleTypeEnum.loader:
        return 'assets/icons/vehicle_loader.png';
      case VehicleTypeEnum.other:
        return 'assets/icons/vehicle_other.png';
      case VehicleTypeEnum.unknown:
      default:
        return 'assets/icons/vehicle_unknown.png';
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
