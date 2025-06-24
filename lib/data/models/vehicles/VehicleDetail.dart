// lib/data/models/vehicles/VehicleDetail.dart

class VehicleDetail {
  final String plate;
  final String position;
  final String connection;
  final String status;
  final DateTime? lastReport;
  final String location;
  final double? batteryVolt;
  final String fuelCutoff;

  VehicleDetail({
    required this.plate,
    required this.position,
    required this.connection,
    required this.status,
    this.lastReport,
    required this.location,
    this.batteryVolt,
    required this.fuelCutoff,
  });

  // --- FACTORY CORREGIDO Y MÁS ROBUSTO ---
  factory VehicleDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    // --- CAMBIO 1: Helper para parsear números de forma segura ---
    // Esta pequeña función interna revisa si el valor es un número o un texto
    // que se pueda convertir a número. Si no, devuelve null.
    double? safeParseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value); // tryParse maneja strings vacíos ("") devolviendo null
      }
      return null;
    }

    // --- CAMBIO 2: Helper para parsear fechas de forma segura ---
    // Revisa que el valor sea un String antes de intentar el parseo.
    DateTime? safeParseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value); // tryParse maneja textos inválidos devolviendo null
      }
      return null;
    }

    return VehicleDetail(
      plate: data['plate'] as String? ?? '',
      position: data['position'] as String? ?? 'Inválida',
      connection: data['connection'] as String? ?? 'Offline',
      status: data['status'] as String? ?? 'Apagado',
      
      // Usamos el helper para la fecha
      lastReport: safeParseDateTime(data['last_report']),

      location: data['location'] as String? ?? 'Sin ubicación',
      
      // Usamos el helper para el voltaje. ¡Esto corrige el crash!
      batteryVolt: safeParseDouble(data['battery_volt']),

      fuelCutoff: data['fuel_cutoff'] as String? ?? 'Sin datos',
    );
  }
}