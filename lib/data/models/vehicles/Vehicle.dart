class Vehicle {
  final String plate;
  final String? type;
  final String? model;
  final String? status;

  Vehicle({
    required this.plate,
    this.type,
    this.model,
    this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      plate: json['plate'] ?? '',
      type: json['type'],
      model: json['model'],
      status: json['status'],
    );
  }
}

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
      plate: json['plate'] ?? '',
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
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
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      speed: json['speed'],
    );
  }
}

class VehicleType {
  final String code;
  final String name;

  VehicleType({required this.code, required this.name});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
