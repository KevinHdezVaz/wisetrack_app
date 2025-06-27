import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/models/dashboard/DashboardData.dart';
import 'package:wisetrack_app/data/services/DashboardService.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> with SingleTickerProviderStateMixin {
  late Future<DashboardData> _dashboardDataFuture;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = DashboardService.getDashboardData(rangeInHours: 24);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DashboardData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            _animationController.repeat();
            return Center(
              child: AnimatedTruckProgress(
                animation: _animationController,
              ),
            );
          }

          _animationController.stop();

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return _buildContent(data);
          }
          return const Center(child: Text('No hay datos para mostrar.'));
        },
      ),
    );
  }

  /// Construye el contenido principal de la pantalla con los datos de la API.
  Widget _buildContent(DashboardData data) {
    // --- Lógica para la tarjeta "Estado de la Flota" ---
    final statusLegendItems = data.vehicleStatus.entries
        .map((entry) => LegendItem(
              text: entry.key.replaceAll('_', ' ').replaceAll(' > 1 hora', ''),
              value: entry.value.toString(),
              color: _getColorForStatus(entry.key),
            ))
        .toList();

    // --- Lógica para la tarjeta "Tipos de Vehículo" ---
    final typeLegendItems = data.vehicleTypes.entries
        .where((entry) => entry.value > 0)
        .map((entry) => LegendItem(
              text: entry.key,
              value: entry.value.toString(),
              color: _getColorForVehicleType(entry.key),
            ))
        .toList();

    // --- Lógica para la tarjeta "Alertas del Plan" ---
    final alertLegendItems = data.alertPlan.entries
        .map((entry) => LegendItem(
              text: entry.key.replaceAll('_', ' '),
              value: entry.value.toString(),
              color: _getColorForAlert(entry.key),
            ))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- TARJETA 1: TOTALES GENERALES ---
        MetricCard(
          title: 'Resumen General',
          progressValue: data.totalVehicles > 0 ? data.totalOnline / data.totalVehicles : 0.0,
          progressText: '${data.totalOnline}',
          progressColor: Colors.blue,
          legendItems: [
            LegendItem(
                text: 'Vehículos Totales',
                value: data.totalVehicles.toString(),
                color: Colors.grey.shade400),
            LegendItem(
                text: 'Vehículos En línea',
                value: data.totalOnline.toString(),
                color: Colors.blue),
            LegendItem(
                text: 'Alertas Totales (24h)',
                value: data.totalAlerts.toString(),
                color: Colors.red.shade400),
          ],
        ),
        const SizedBox(height: 16),

        // --- TARJETA 2: ESTADO DE LA FLOTA ---
        MetricCard(
          title: 'Estado de la Flota',
          progressValue: 1.0,
          progressText: '${data.totalVehicles}',
          progressColor: Colors.blue.shade400,
          legendItems: statusLegendItems,
        ),
        const SizedBox(height: 16),

        // --- TARJETA 3: TIPOS DE VEHÍCULO ---
        MetricCard(
          title: 'Tipos de Vehículo',
          progressValue: 1.0,
          progressText: '${data.vehicleTypes.length}',
          progressColor: Colors.green.shade400,
          legendItems: typeLegendItems,
        ),
        const SizedBox(height: 16),

        // --- TARJETA 4: ALERTAS DEL PLAN ---
        MetricCard(
          title: 'Alertas del Plan (24h)',
          progressValue: 1.0,
          progressText: '${data.totalAlerts}',
          progressColor: Colors.orange.shade600,
          legendItems: alertLegendItems,
        ),
      ],
    );
  }

  // --- Helpers para asignar colores dinámicamente ---
  Color _getColorForStatus(String status) {
    switch (status) {
      case 'En ruta':
        return Colors.blue.shade400;
      case 'Sin Transmision':
        return Colors.orange.shade400;
      case 'Ralentí':
        return Colors.yellow.shade700;
      case 'Apagado_>_1_hora':
        return Colors.grey.shade500;
      default:
        return Colors.black;
    }
  }

  Color _getColorForVehicleType(String typeName) {
    return Colors.primaries[typeName.hashCode % Colors.primaries.length];
  }

  Color _getColorForAlert(String alertType) {
    switch (alertType) {
      case 'Exceso_de_velocidad':
        return Colors.red.shade400;
      case 'Encendido_de_motor':
        return Colors.purple.shade400;
      case 'Zona_peligrosa':
        return Colors.deepOrange.shade400;
      case 'En_Destino':
        return Colors.green.shade400;
      case 'En_Ruta':
        return Colors.lightBlue.shade400;
      default:
        return Colors.red.shade300;
    }
  }
}

// --- WIDGETS REUTILIZABLES ---
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
      elevation: 10,
            color: Colors.white, // Fondo blanco explícito

      shadowColor: Colors.black,
shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        // Añadimos el borde "medio negro" (un gris claro)
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),      child: Padding(
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
                    children: legendItems.isEmpty
                        ? [const Text('No hay datos para esta categoría.')]
                        : legendItems
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

class CircularMetricIndicator extends StatelessWidget {
  final double value;
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

class LegendItem {
  final String text;
  final String value;
  final Color color;

  const LegendItem(
      {required this.text, required this.value, required this.color});
}