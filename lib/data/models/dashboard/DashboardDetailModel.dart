import 'dart:convert';

class DashboardDetailData {
  final Map<String, int> breakdown;
  final int total;

  DashboardDetailData({
    required this.breakdown,
    required this.total,
  });

  factory DashboardDetailData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    // El mapa de desglose puede tener diferentes claves ('d_alert_plan', etc.)
    // Buscamos la primera clave que sea un mapa.
    final breakdownKey = data.keys.firstWhere(
      (key) => data[key] is Map,
      orElse: () => 'unknown',
    );
    
    final breakdownMap = data[breakdownKey] as Map<String, dynamic>? ?? {};
    
    // El total también tiene una clave variable ('total_alerts', 'total_vehicles', etc.)
    final totalKey = data.keys.firstWhere(
      (key) => key.startsWith('total_'),
      orElse: () => 'unknown',
    );

    return DashboardDetailData(
      breakdown: breakdownMap.map((key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0)),
      total: data[totalKey] as int? ?? 0,
    );
  }
}