import 'dart:async';
import 'package:flutter/material.dart';
 import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wisetrack_app/data/models/vehicles/VehicleHistoryPoint.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/CustomDatePickerDialog.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';
import 'package:geolocator/geolocator.dart';
// Importamos nuestra clase de utilidades
import 'package:wisetrack_app/utils/pdf_report_generator.dart';

class AuditDetailsScreen extends StatefulWidget {
  final String plate;

  const AuditDetailsScreen({Key? key, required this.plate}) : super(key: key);

  @override
  _AuditDetailsScreenState createState() => _AuditDetailsScreenState();
}

class _AuditDetailsScreenState extends State<AuditDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  final List<String> _timeRanges = ['24 horas', '12 horas', '8 horas'];
  String _selectedRange = '24 horas';
  bool _isRangeDropdownOpen = false;

  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  List<HistoryPoint> _historyPoints = [];

  String _distanceTraveled = "0 Km";
  String _averageSpeed = "0 km/h";
  String _maxSpeed = "0 km/h";
  String _totalTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _fetchHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _animationController.repeat();

    try {
      final endDate = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 23, 59, 59);
      int hoursToSubtract = int.parse(_selectedRange.split(' ')[0]);

      final history = await VehicleService.getVehicleHistoryByRange(
        plate: widget.plate,
        endDate: endDate,
        rangeInHours: hoursToSubtract,
      );

      if (mounted) {
        _historyPoints = history;
        if (_historyPoints.isNotEmpty) {
          _updateMapWithHistory();
          _calculateAndSetMetrics();
        } else {
          _polylines.clear();
          _markers.clear();
          _resetMetrics();
        }
      }
    } catch (e) {
      if (mounted) {
        _errorMessage = "Error al cargar el historial.";
        debugPrint("Error en fetchHistory: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  void _updateMapWithHistory() async {
    if (_historyPoints.isEmpty) return;

    final points =
        _historyPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();

    _polylines.clear();
    _markers.clear();

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: AppColors.primary,
        width: 5,
      ),
    );

    _markers.add(Marker(
        markerId: const MarkerId('start'),
        position: points.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
    _markers.add(Marker(
        markerId: const MarkerId('end'),
        position: points.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));

    if (_mapController.isCompleted) {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
              points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
              points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b)),
          northeast: LatLng(
              points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
              points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b)),
        ),
        50.0,
      ));
    }
    setState(() {});
  }

  void _calculateAndSetMetrics() {
    if (_historyPoints.length < 2) {
      _resetMetrics();
      return;
    }

    double totalDistance = 0;
    for (int i = 0; i < _historyPoints.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        _historyPoints[i].latitude,
        _historyPoints[i].longitude,
        _historyPoints[i + 1].latitude,
        _historyPoints[i + 1].longitude,
      );
    }
    _distanceTraveled = "${(totalDistance / 1000).toStringAsFixed(1)} Km";

    double maxSpeed = 0;
    double totalSpeed = 0;
    int speedPointsCount = 0;
    for (var point in _historyPoints) {
      if (point.speed > maxSpeed) maxSpeed = point.speed;
      if (point.speed > 0) {
        totalSpeed += point.speed;
        speedPointsCount++;
      }
    }
    _maxSpeed = "${maxSpeed.toStringAsFixed(0)} km/h";
    _averageSpeed = speedPointsCount > 0
        ? "${(totalSpeed / speedPointsCount).toStringAsFixed(0)} km/h"
        : "0 km/h";

    final duration =
        _historyPoints.last.timestamp!.difference(_historyPoints.first.timestamp!);
    _totalTime = duration.toString().split('.').first.padLeft(8, "0");

    setState(() {});
  }

  void _resetMetrics() {
    setState(() {
      _distanceTraveled = "0 Km";
      _averageSpeed = "0 km/h";
      _maxSpeed = "0 km/h";
      _totalTime = "00:00:00";
    });
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) =>
          DatePickerBottomSheet(initialDate: _selectedDate),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
      _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: Text(widget.plate,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                const CameraPosition(target: LatLng(-33.045, -71.619), zoom: 13.0),
            polylines: _polylines,
            markers: _markers,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
          ),
          if (!_isLoading) _buildContentSheet(),
          if (_isLoading)
            Positioned.fill(
                child: AnimatedTruckProgress(animation: _animationController)),
        ],
      ),
    );
  }

  Widget _buildContentSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.2,
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
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            children: [
              _buildDriverInfo(),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 12),
              _buildRangeDropdown(),
              const SizedBox(height: 20),
              _buildMetricsRow(),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Center(
                    child: Text(_errorMessage!,
                        style: const TextStyle(color: Colors.red))),
              if (!_isLoading && _historyPoints.isEmpty && _errorMessage == null)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'No se encontraron recorridos para la fecha y rango seleccionados.'),
                )),
              _buildDownloadButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsRow() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildMetricCard(_distanceTraveled, 'Distancia recorrida'),
          _buildMetricCard(_averageSpeed, 'Velocidad promedio'),
          _buildMetricCard(_maxSpeed, 'Velocidad máxima'),
          _buildMetricCard(_totalTime, 'Tiempo total'),
        ],
      ),
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
              DateFormat('dd / MM / yy', 'es_ES').format(_selectedDate),
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
                    onTap: () {
                      setState(() {
                        _selectedRange = range;
                        _isRangeDropdownOpen = false;
                      });
                      _fetchHistory();
                    },
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
        const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5')),
        const SizedBox(width: 12),
        const Text('Conductor',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const Spacer(),
        const Text('Antonio López',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label) {
    return SizedBox(
      width: 130,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 12)),
          ],
        ),
      ),
    );
  }
Widget _buildDownloadButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        // --- LÓGICA CORREGIDA ---
        // El botón solo depende de si la carga ha finalizado.
        onPressed: !_isLoading
            ? () {
                // Llama al método estático. Si no hay historial,
                // enviará los valores iniciales (ej: "0 Km").
                PdfReportGenerator.generateAuditReport(
                  context: context,
                  plate: widget.plate,
                  selectedDate: _selectedDate,
                  selectedRange: _selectedRange,
                  distance: _distanceTraveled,
                  avgSpeed: _averageSpeed,
                  maxSpeed: _maxSpeed,
                  totalTime: _totalTime,
                );
              }
            : null, // Botón desactivado SÓLO mientras está cargando.
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text('Descargar',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          // El color también depende solo de si la carga ha finalizado.
          backgroundColor: !_isLoading ? AppColors.primary : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
    ),
  );
}
}