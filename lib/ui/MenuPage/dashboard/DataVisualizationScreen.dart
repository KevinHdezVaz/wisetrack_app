import 'package:flutter/material.dart';

import 'package:wisetrack_app/data/models/BarChartDataModel.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/DataVisualizationDetail.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class DataVisualizationScreen extends StatelessWidget {
  const DataVisualizationScreen({Key? key}) : super(key: key);

  static const List<BarChartDataModel> mobilesData = [
    BarChartDataModel(label: 'Cama baja', value: 32, color: Color(0xFF00636A)),
    BarChartDataModel(label: 'Camión ¾', value: 8, color: Colors.teal),
    BarChartDataModel(label: 'Rampla fría', value: 25, color: Colors.lightBlue),
    BarChartDataModel(label: 'Rampla seca', value: 20, color: Colors.orange),
  ];

  static const List<BarChartDataModel> plannedData = [
    BarChartDataModel(label: 'Extra 5', value: 50, color: Colors.grey),
    BarChartDataModel(label: 'Extra 4', value: 75, color: Colors.indigo),
    BarChartDataModel(label: 'Extra 3', value: 90, color: Colors.deepOrange),
    BarChartDataModel(label: 'Extra 2', value: 110, color: Colors.orange),
    BarChartDataModel(label: 'Extra 1', value: 220, color: Colors.lightBlue),
    BarChartDataModel(
        label: 'En Destino', value: 100, color: Color(0xFF00636A)),
    BarChartDataModel(label: 'En Origen', value: 80, color: Color(0xFF00636A)),
  ];

  static const List<BarChartDataModel> fleetStatusData = [
    BarChartDataModel(
        label: 'Sin transmisión', value: 1.5, color: Colors.orange),
    BarChartDataModel(
        label: 'Apagado > 1H', value: 2.1, color: Colors.deepOrange),
    BarChartDataModel(label: 'Ralentí', value: 2.8, color: Colors.lightBlue),
    BarChartDataModel(label: 'En ruta', value: 4.5, color: Color(0xFF00636A)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- INICIO DE LA MODIFICACIÓN ---

      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          ChartCard(
              title: 'Móviles',
              data: mobilesData,
              totalLabel: 'Móviles totales',
              totalValue: '78',
              maxValue: 35),
          const SizedBox(height: 16),
          ChartCard(
              title: 'Planificados',
              data: plannedData,
              totalLabel: 'Alertas totales',
              totalValue: '1037',
              maxValue: 400),
          const SizedBox(height: 16),
          ChartCard(
              title: 'Estados Flota',
              data: fleetStatusData,
              totalLabel: 'Total en línea',
              totalValue: '13',
              maxValue: 5),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}

class ChartCard extends StatelessWidget {
  final String title;
  final List<BarChartDataModel> data;
  final String totalLabel;
  final String totalValue;
  final double maxValue;

  const ChartCard({
    Key? key,
    required this.title,
    required this.data,
    required this.totalLabel,
    required this.totalValue,
    required this.maxValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Datavisualizationdetail(),
          ),
        );
      },
      child: Card(
        elevation: 12,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
            color: Colors.grey, // Color del borde
            width: 1.0, // Grosor del borde
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildHorizontalBarChart(),
              const SizedBox(height: 16),
              const Divider(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.grey),
            onPressed: () {}),
      ],
    );
  }

  /// Construye el gráfico de barras horizontales manualmente
  Widget _buildHorizontalBarChart() {
    return Column(
      children: [
        ...data.map((item) => _buildBarRow(item)).toList(),
        const SizedBox(height: 8),
        _buildXAxis(),
      ],
    );
  }

  Widget _buildBarRow(BarChartDataModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              item.label,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            // --- INICIO DE LA MODIFICACIÓN ---
            // Usamos un Stack para poner el fondo detrás de la barra de progreso
            child: Stack(
              children: [
                // 1. El contenedor de fondo (el "riel")
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // 2. La barra de progreso (el valor)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth =
                        (item.value / maxValue) * constraints.maxWidth;
                    return Container(
                      height: 20,
                      width: barWidth > constraints.maxWidth
                          ? constraints.maxWidth
                          : barWidth,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ],
            ),
            // --- FIN DE LA MODIFICACIÓN ---
          ),
        ],
      ),
    );
  }

  Widget _buildXAxis() {
    return Padding(
      padding: const EdgeInsets.only(left: 100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int numberOfLabels = 8;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(numberOfLabels, (index) {
              int labelValue =
                  (maxValue / (numberOfLabels - 1) * index).round();
              return Text(
                labelValue.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$totalLabel: $totalValue',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          InkWell(
            onTap: () {/* TODO: Lógica para "Ver más" */},
            child: Row(
              children: [
                Text('Ver más', style: TextStyle(color: AppColors.primary)),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
