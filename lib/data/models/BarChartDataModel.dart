// archivo: chart_data_model.dart (o en el mismo archivo de la pantalla)
import 'package:flutter/material.dart';

class BarChartDataModel {
  final String label;
  final double value;
  final Color color;

  const BarChartDataModel({
    required this.label,
    required this.value,
    required this.color,
  });
}
