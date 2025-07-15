import 'package:flutter/material.dart';
 import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wisetrack_app/data/models/NotificationItem.dart' as model;
 
 import 'package:wisetrack_app/data/services/NotificationsService.dart';
 import 'package:wisetrack_app/ui/color/app_colors.dart';

class NotificationDetailScreen extends StatefulWidget {
  final int notificationId;

  const NotificationDetailScreen({Key? key, required this.notificationId})
      : super(key: key);

  @override
  _NotificationDetailScreenState createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  model.NotificationDetail? _notificationDetail;

  @override
  void initState() {
    super.initState();
    _fetchNotificationDetails();
  }

  Future<void> _fetchNotificationDetails() async {
    try {
      final detail = await NotificationService.getNotificationDetail(
          notificationId: widget.notificationId);
      if (mounted) {
        setState(() {
          _notificationDetail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al cargar el detalle de la notificación.";
          _isLoading = false;
        });
        debugPrint("Error fetching details: $e");
      }
    }
  }

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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_errorMessage != null) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
          ));
    }
    if (_notificationDetail == null) {
      return const Center(child: Text('No se encontraron detalles para la notificación.'));
    }

    final detail = _notificationDetail!;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildNotificationHeader(detail),
            const SizedBox(height: 24),
            if (detail.alert.latitude != null && detail.alert.longitude != null)
              _buildMapView(detail)
            else
              _buildNoLocationView(),
            const SizedBox(height: 40),
            _buildDetailsSection(detail),
            const SizedBox(height: 100), // Espacio para el botón flotante
          ],
        ),
        _buildShareButton(),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
  
  Widget _buildNotificationHeader(model.NotificationDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                detail.messageTitle,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('HH:mm a').format(detail.date),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          detail.messageBody,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildMapView(model.NotificationDetail detail) {
    final location = LatLng(detail.alert.latitude!, detail.alert.longitude!);
    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 15.0,
          ),
          markers: {
            Marker(
              markerId: MarkerId(detail.id.toString()),
              position: location,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          },
          zoomControlsEnabled: false,
        ),
      ),
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

  Widget _buildDetailsSection(model.NotificationDetail detail) {
    return Column(
      children: [
        _buildDetailRow(
          icon: const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 18, color: Colors.white)),
          label: 'Conductor:',
          value: detail.alert.driver,
        ),
        // La geocerca no está disponible en este endpoint, se omite.
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
      // El color de fondo es transparente para no ocultar el contenido de la lista al hacer scroll.
      // Se usa un gradiente sutil para que el botón se destaque sobre el contenido.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.5, 1.0],
        ),
      ),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Asegúrate de que los detalles de la notificación no sean nulos
          if (_notificationDetail != null) {
            final detail = _notificationDetail!;
            
            // 1. Construye el mensaje de texto a compartir
            final dateString = DateFormat('dd/MM/yyyy HH:mm a').format(detail.date);
            
            String shareText = "🔔 *Alerta WiseTrack*\n\n"
                "*${detail.messageTitle}*\n"
                "${detail.messageBody}\n\n"
                "👤 *Conductor:* ${detail.alert.driver}\n"
                "📅 *Fecha:* $dateString";

            // 2. Agrega el enlace de Google Maps si hay coordenadas
            if (detail.alert.latitude != null && detail.alert.longitude != null) {
              final lat = detail.alert.latitude;
              final lon = detail.alert.longitude;
              final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
              shareText += "\n\n📍 *Ubicación:*\n$googleMapsUrl";
            }

            // 3. Usa el paquete para mostrar el diálogo de compartir
            Share.share(shareText);
          }
        },
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text(
          'Compartir',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    ),
  );
}
}