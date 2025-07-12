import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wisetrack_app/data/models/alert/AlertModel.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Alertas alert;

  const NotificationDetailScreen({Key? key, required this.alert})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: const Text('Detalle de Notificación',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildNotificationHeader(alert),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              if (alert.latitude != null && alert.longitude != null)
                _buildMapView(alert)
              else
                _buildNoLocationView(),
              const SizedBox(height: 40),
              _buildDetailsSection(alert),
              const SizedBox(height: 100),
            ],
          ),
          _buildShareButton(),
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

  Widget _buildNotificationHeader(Alertas alert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                alert.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              alert.alertDate != null
                  ? DateFormat('HH:mm a').format(alert.alertDate!)
                  : '',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 16, color: Colors.grey.shade800, height: 1.4),
            children: [
              const TextSpan(text: 'El vehículo '),
              TextSpan(
                text: alert.plate,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(text: ' generó la alerta.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapView(Alertas alert) {
    final location = LatLng(alert.latitude!, alert.longitude!);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 250,
          width: constraints.maxWidth, // Usa el ancho máximo disponible
          child: ClipRRect(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: location,
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(alert.plate),
                  position: location,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
              },
              zoomControlsEnabled: false,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoLocationView() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('No hay ubicación disponible para esta alerta.'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(Alertas alert) {
    return Column(
      children: [
        _buildDetailRow(
          icon: const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 18, color: Colors.white)),
          label: 'Conductor:',
          value: alert.driverName,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          icon:
              const Icon(Icons.location_on, color: AppColors.primary, size: 30),
          label: 'Geocerca:',
          value: alert.geofenceName ??
              'No aplica', // Muestra 'No aplica' si es nulo
        ),
      ],
    );
  }

  Widget _buildDetailRow(
      {required Widget icon, required String label, required String value}) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share, color: Colors.white),
          label: const Text('Compartir',
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
