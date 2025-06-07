import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/CustomDatePickerDialog.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class Auditdetailsscreen extends StatefulWidget {
  const Auditdetailsscreen({Key? key}) : super(key: key);

  @override
  _AuditScreenState createState() => _AuditScreenState();
}

class _AuditScreenState extends State<Auditdetailsscreen> {
  DateTime _selectedDate = DateTime(2025, 5, 12);
  final List<String> _timeRanges = ['24 horas', '12 horas', '8 horas'];
  String _selectedRange = '24 horas';
  bool _isRangeDropdownOpen = false;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-33.045, -71.619),
    zoom: 13.0,
  );
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setMapRoute();
  }

  void _setMapRoute() {
    setState(() {
      _markers.add(
        const Marker(
          markerId: MarkerId('vehicle_location'),
          position: LatLng(-33.045, -71.619),
        ),
      );
      _polylines.add(
        const Polyline(
          polylineId: PolylineId('route1'),
          points: [
            LatLng(-33.04, -71.62),
            LatLng(-33.042, -71.618),
            LatLng(-33.045, -71.619),
            LatLng(-33.047, -71.622),
          ],
          color: AppColors.primary,
          width: 5,
        ),
      );
    });
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerBottomSheet(initialDate: _selectedDate);
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: const Text('AAAA - 12',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            polylines: _polylines,
            markers: _markers,
            zoomControlsEnabled: false,
          ),
          _buildContentSheet(),
          _buildDownloadButton(),
        ],
      ),
    );
  }

  Widget _buildContentSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
            children: [
              _buildDriverInfo(),
              const SizedBox(height: 0),
              const SizedBox(height: 16), // Reducimos el espacio
              _buildDatePicker(context),
              const SizedBox(height: 12), // Reducimos el espacio
              _buildRangeDropdown(),
              const SizedBox(height: 20), // Espacio final
              _buildMetricsRow(), // MOVIMOS LAS MÉTRICAS ARRIBA DEL DATE PICKER
            ],
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCustomDatePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.grey),
            const SizedBox(width: 12),
            const Text('Cuándo'),
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

  Widget _buildRangeDropdown() {
    return Column(
      children: [
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () =>
                setState(() => _isRangeDropdownOpen = !_isRangeDropdownOpen),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Text('Seleccione rango'),
                  const Spacer(),
                  Text(_selectedRange,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Icon(_isRangeDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: _isRangeDropdownOpen,
          child: Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: _timeRanges.map((range) {
                bool isSelected = range == _selectedRange;
                return Material(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() {
                      _selectedRange = range;
                      _isRangeDropdownOpen = false;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(range,
                            style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      children: [
        // Avatar
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
        ),
        const SizedBox(width: 12),

        // Texto "Conductor" alineado a la izquierda
        const Text('Conductor',
            style: TextStyle(color: Colors.grey, fontSize: 14)),

        // Espacio flexible que empuja el nombre a la derecha
        const Spacer(),

        // Nombre alineado a la derecha
        const Text('Antonio López',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return SizedBox(
      height: 120, // Fixed height to contain the cards
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildMetricCard('5 Km', 'Distancia recorrida'),
          _buildMetricCard('120 km/h', 'Velocidad promedio'),
          _buildMetricCard('240 km/h', 'Velocidad maxima'),
          _buildMetricCard('24:00:00', 'Tiempo total'),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String value, String label) {
    return SizedBox(
      width: 160,
      child: SizedBox(
        height: 80, // Fixed height for the card (adjust as needed)
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.white.withOpacity(0.8),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(
            bottom: 20.0), // Agrega espacio en la parte inferior
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
