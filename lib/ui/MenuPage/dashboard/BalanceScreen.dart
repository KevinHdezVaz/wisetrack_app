import 'package:flutter/material.dart';
import 'dart:math';

// Asegúrate de que la ruta a tus colores sea la correcta
// import 'app_colors.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.grey[50],
        leading: _buildBackButton(context),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance de Hoy',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            Text(
              'Lun 12 may.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () {
              // TODO: Lógica para refrescar datos
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {
              // TODO: Lógica para más opciones
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          MetricCard(
            title: 'Flota activa',
            progressValue: 0.94,
            progressText: '94%',
            progressColor: Colors.teal.shade400,
            legendItems: const [
              LegendItem(
                  text: 'Reportando (48 Hrs)',
                  value: '50 Móviles',
                  color: Colors.teal),
              LegendItem(
                  text: 'Sin reportar (48 Hrs)',
                  value: '3 Móviles',
                  color: Colors.teal),
            ],
          ),
          const SizedBox(height: 16),
          MetricCard(
            title: 'Rendimiento promedio',
            progressValue: 0.91,
            progressText: '91%',
            progressColor: Colors.cyan.shade400,
            legendItems: const [
              LegendItem(
                  text: 'Óptimo cliente',
                  value: '3,7 Km/L',
                  color: Colors.cyan),
              LegendItem(text: 'Actual', value: '3,4 Km/L', color: Colors.cyan),
            ],
          ),
          const SizedBox(height: 16),
          MetricCard(
            title: 'Costo combustible',
            progressValue: 1.0, // El círculo está completo
            progressText: '3,7',
            progressColor: Colors.orange.shade400,
            legendItems: const [
              LegendItem(
                  text: 'Promedio',
                  value: '3,4 Km/L',
                  color: Colors.cyan), // Color diferente como en la imagen
              LegendItem(
                  text: 'Actual', value: '3,7 Km/L', color: Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          MetricCard(
            title: 'Cumplimiento de viajes',
            progressValue: 0.83,
            progressText: '83%',
            progressColor: Colors.orange.shade600,
            legendItems: const [
              LegendItem(text: 'Planificados', value: '85', color: Colors.cyan),
              LegendItem(text: 'Realizados', value: '71', color: Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          MetricCard(
            title: 'Tasa de consumo en ralentí',
            progressValue: 0.028, // 2.8%
            progressText: '2,8%',
            progressColor: Colors.deepOrange.shade400,
            legendItems: const [
              LegendItem(
                  text: 'Total (L) consumidos',
                  value: '3600',
                  color: Colors.cyan),
              LegendItem(
                  text: '(L) en ralentí', value: '102', color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/backbtn.png',
        width: 40,
        height: 40,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}

/// WIDGET REUTILIZABLE PARA LAS TARJETAS DE MÉTRICAS
class MetricCard extends StatelessWidget {
  final String title;
  final double progressValue;
  final String progressText;
  final Color progressColor;
  final List<LegendItem> legendItems;

  const MetricCard({
    Key? key,
    required this.title,
    required this.progressValue,
    required this.progressText,
    required this.progressColor,
    required this.legendItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                CircularMetricIndicator(
                  value: progressValue,
                  text: progressText,
                  color: progressColor,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems
                        .map((item) => _buildLegendRow(item))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(LegendItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(item.text, style: TextStyle(color: Colors.grey[700]))),
          Text(item.value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// WIDGET REUTILIZABLE PARA EL INDICADOR CIRCULAR
class CircularMetricIndicator extends StatelessWidget {
  final double value; // de 0.0 a 1.0
  final String text;
  final Color color;

  const CircularMetricIndicator({
    Key? key,
    required this.value,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 8,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}

/// CLASE AUXILIAR PARA LOS ITEMS DE LA LEYENDA
class LegendItem {
  final String text;
  final String value;
  final Color color;

  const LegendItem(
      {required this.text, required this.value, required this.color});
}
