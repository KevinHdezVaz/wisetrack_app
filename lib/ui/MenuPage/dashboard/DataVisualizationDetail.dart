import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:wisetrack_app/data/models/BarChartDataModel.dart';
import 'package:wisetrack_app/data/models/dashboard/DashboardDetailModel.dart';
import 'package:wisetrack_app/data/services/DashboardService.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/CustomDatePickerDialog.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class DataVisualizationDetail extends StatefulWidget {
  final String title;
  final String dataType; // ej: "d_vehicles_type"

  const DataVisualizationDetail({
    Key? key,
    required this.title,
    required this.dataType,
  }) : super(key: key);

  @override
  _DataVisualizationDetailState createState() =>
      _DataVisualizationDetailState();
}

class _DataVisualizationDetailState extends State<DataVisualizationDetail> {
  // Estado para manejar la fecha y los datos
  DateTime _selectedDate = DateTime.now();
  Future<DashboardDetailData>? _detailDataFuture;

  @override
  void initState() {
    super.initState();
    // Llama al servicio para la carga inicial de datos
    _fetchDetails();
  }

  /// Llama al servicio para obtener los datos de detalle y actualiza el Future.
  void _fetchDetails() {
    setState(() {
      _detailDataFuture = DashboardService.getDashboardDetailData(
        rangeInHours: 24, // o el rango que necesites
        dataType: widget.dataType,
        // Pasamos la fecha seleccionada al servicio (necesitarás ajustar el servicio si no lo hiciste)
        // Por ahora, asumimos que el servicio usa la fecha actual si no se especifica.
      );
    });
  }

  /// Muestra el BottomSheet del calendario y actualiza la fecha.
  Future<void> _showCustomDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DatePickerBottomSheet(initialDate: _selectedDate);
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        // Al cambiar la fecha, se vuelve a llamar al servicio para refrescar los datos.
        _fetchDetails();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _buildBackButton(context),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, // Título dinámico
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            Text(DateFormat('EEE, d MMM', 'es_ES').format(_selectedDate), // Fecha dinámica
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
      body: FutureBuilder<DashboardDetailData>(
        future: _detailDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.hasData) {
            final detailData = snapshot.data!;
            return _buildContent(detailData);
          }
          return const Center(child: Text("No hay datos disponibles."));
        },
      ),
    );
  }

  Widget _buildContent(DashboardDetailData detailData) {
    // Mapeamos los datos del servicio al formato del gráfico
    final chartData = detailData.breakdown.entries.map((entry) {
      return BarChartDataModel(
        label: entry.key.replaceAll('_', ' '),
        value: entry.value.toDouble(),
        color: Colors.primaries[entry.key.hashCode % Colors.primaries.length]
      );
    }).toList()..sort((a,b) => b.value.compareTo(a.value));
    
    final maxValue = detailData.breakdown.values.isEmpty 
      ? 1.0 
      : detailData.breakdown.values.reduce(max).toDouble() * 1.1;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDatePicker(context),
            const SizedBox(height: 16),
            _buildChartCard(chartData, maxValue, detailData.total.toString()),
            const SizedBox(height: 100),
          ],
        ),
        _buildDownloadButton(),
      ],
    );
  }



  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      // Al tocar este widget, se llama a la función que muestra el BottomSheet
      onTap: () => _showCustomDatePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey),
            boxShadow: [
              BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.05))
            ]),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text(
              'Cuándo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              DateFormat('dd / MM / yyyy', 'es_ES').format(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChartCard(List<BarChartDataModel> data, double maxValue, String totalValue) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide.none),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHorizontalBarChart(data, maxValue),
            const SizedBox(height: 16),
            const Divider(),
            _buildFooter(totalValue),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBarChart(List<BarChartDataModel> data, double maxValue) {
    if (data.isEmpty) {
      return const SizedBox(height: 100, child: Center(child: Text("No hay datos para este período.")));
    }
    return Column(
      children: [
        ...data.map((item) => _buildBarRow(item, maxValue)).toList(),
        const SizedBox(height: 8),
        _buildXAxis(maxValue),
      ],
    );
  }
  

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildBarRow(BarChartDataModel item, double maxValue) {
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
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = maxValue > 0 ? (item.value / maxValue) * constraints.maxWidth : 0;
                    return Container(
                      height: 20,
                      width: barWidth.clamp(0.0, constraints.maxWidth).toDouble(),
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXAxis(double maxValue) {
    return Padding(
      padding: const EdgeInsets.only(left: 100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int numberOfLabels = 5;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(numberOfLabels, (index) {
              int labelValue = (maxValue / (numberOfLabels - 1) * index).round();
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
  
  Widget _buildFooter(String totalValue) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(totalValue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

 
 

  Widget _buildDownloadButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {/* TODO: Lógica de descarga */},
          icon: const Icon(Icons.download, color: Colors.white),
          label: const Text('Descargar',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
      ),
    );
  }
}
