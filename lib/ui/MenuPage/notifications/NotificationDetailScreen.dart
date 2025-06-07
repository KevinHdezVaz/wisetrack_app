import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
// Asegúrate de que la ruta a tus colores sea la correcta
// import 'app_colors.dart';

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({Key? key}) : super(key: key);

  // Datos de ejemplo para la pantalla
  static const String vehicleId = 'AAAA - 12';
  static const LatLng _notificationLocation =
      LatLng(-33.518, -70.713); // Coordenadas de ejemplo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: const Text('Notificaciones',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Usamos un ListView para que todo el contenido, incluido el mapa, sea desplazable.
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildNotificationHeader(),
              const SizedBox(height: 16),
              _buildMapView(),
              const SizedBox(height: 24),
              _buildDetailsSection(),
              const SizedBox(
                  height:
                      100), // Espacio para que el botón no tape el contenido
            ],
          ),
          // Botón de compartir fijo en la parte inferior
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

  Widget _buildNotificationHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Exceso de velocidad',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '07:00 AM',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Usamos RichText para poner en negrita solo una parte del texto
        RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 16, color: Colors.grey.shade800, height: 1.4),
            children: const [
              TextSpan(text: 'El vehículo '),
              TextSpan(
                text: vehicleId,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                  text:
                      ' superó el límite de velocidad permitido en Autopista Sur.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _notificationLocation,
            zoom: 14.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('notification_location'),
              position: _notificationLocation,
              // TODO: Reemplazar con tu ícono de marcador personalizado
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          },
          zoomControlsEnabled: false,
          scrollGesturesEnabled:
              false, // Opcional: para que el mapa no sea interactivo
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        _buildDetailRow(
          icon: const CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
          ),
          label: 'Conductor:',
          value: 'Claudio Zamorano',
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          icon:
              const Icon(Icons.location_on, color: AppColors.primary, size: 30),
          label: 'Posición:',
          value: 'Maipú, Región Metropolitana',
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
          onPressed: () {
            // TODO: Lógica para compartir
          },
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
