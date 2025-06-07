import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Asegúrate de que las rutas a tus archivos sean correctas
import 'package:wisetrack_app/data/models/BarChartDataModel.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/CustomDatePickerDialog.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class Datavisualizationdetail extends StatefulWidget {
  const Datavisualizationdetail({Key? key}) : super(key: key);

  @override
  _DatavisualizationdetailState createState() =>
      _DatavisualizationdetailState();
}

// La lógica y las variables ahora están dentro de la clase de Estado
class _DatavisualizationdetailState extends State<Datavisualizationdetail> {
  // --- VARIABLES Y DATOS DE LA PANTALLA ---
  static final List<BarChartDataModel> alertsData = [
    BarChartDataModel(
        label: 'Exceso de velocidad', value: 360, color: AppColors.primary),
    BarChartDataModel(
        label: 'Encendido de motor', value: 90, color: Colors.teal),
    BarChartDataModel(
        label: 'Zona peligrosa', value: 230, color: Colors.lightBlue),
    BarChartDataModel(label: 'Extra 1', value: 100, color: Colors.deepOrange),
    BarChartDataModel(label: 'Extra 2', value: 90, color: Colors.orange),
    BarChartDataModel(
        label: 'Extra 3', value: 80, color: Colors.deepOrange.shade200),
    BarChartDataModel(label: 'Extra 4', value: 70, color: Colors.indigo),
    BarChartDataModel(label: 'Extra 5', value: 60, color: Colors.grey),
  ];
  static const double maxValue = 400;
  DateTime _selectedDate = DateTime(2025, 5, 12);

  // --- INICIO DE LA MODIFICACIÓN ---
  /// Muestra el BottomSheet del calendario y actualiza la fecha.
  Future<void> _showCustomDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // Llamamos al widget del BottomSheet que creamos anteriormente
        return DatePickerBottomSheet(initialDate: _selectedDate);
      },
    );

    // Si el usuario confirma una fecha, actualizamos el estado para redibujar la UI
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  // --- FIN DE LA MODIFICACIÓN ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _buildBackButton(context),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alertas',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            Text('San Isidro - Lun 12 may.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black54),
              onPressed: () {/* TODO: Lógica para más opciones */})
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDatePicker(context),
              const SizedBox(height: 16),
              _buildChartCard(),
              const SizedBox(height: 100),
            ],
          ),
          _buildDownloadButton(),
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

  // --- El resto de los métodos no necesitan cambios ---

  Widget _buildChartCard() {
    return Card(
      color: Colors.white,
      elevation: 0, // Elimina la sombra
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // Sin bordes redondeados
        side: BorderSide.none, // Elimina el borde
      ),
      margin: EdgeInsets.zero, // Elimina el margen exterior
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHorizontalBarChart(),
            const SizedBox(height: 16),
            const Divider(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBarChart() {
    return Column(
      children: [
        ...alertsData.map((item) => _buildBarRow(item)).toList(),
        const SizedBox(height: 8),
        _buildXAxis(),
      ],
    );
  }

  Widget _buildBarRow(BarChartDataModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinea elementos al inicio vertical
        children: [
          SizedBox(
            width: 80, // Ancho fijo para las etiquetas
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // Alinea texto a la derecha
              children: [
                Text(
                  item.label,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  softWrap: true, // Permite múltiples líneas
                ),
                if (item.label ==
                    'Exceso de velocidad') // Espacio adicional solo para este item
                  const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  margin: item.label == 'Exceso de velocidad'
                      ? const EdgeInsets.only(
                          top: 8) // Ajuste de margen para alinear la barra
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth =
                        (item.value / maxValue) * constraints.maxWidth;
                    return Container(
                      height: 20,
                      margin: item.label == 'Exceso de velocidad'
                          ? const EdgeInsets.only(
                              top: 8) // Ajuste de margen para alinear la barra
                          : EdgeInsets.zero,
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
          ),
        ],
      ),
    );
  }

  Widget _buildXAxis() {
    return Padding(
      padding: const EdgeInsets.only(left: 120),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int numberOfLabels = 9;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(numberOfLabels, (index) {
              int labelValue =
                  (maxValue / (numberOfLabels - 1) * index).round();
              return Text(labelValue.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey));
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Alertas totales:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text('1037',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
