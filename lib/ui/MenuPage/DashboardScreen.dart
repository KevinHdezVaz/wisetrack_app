// archivo: dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wisetrack_app/ui/MenuPage/AppDrawer.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'dart:async';

import 'package:wisetrack_app/ui/profile/EditProfileScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};

  // Posición inicial del mapa, centrada en la zona de las imágenes.
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(
        -32.775, -71.229), // Coordenadas aproximadas de La Calera/La Ligua
    zoom: 11.0,
  );

  @override
  void initState() {
    super.initState();
    // Carga los marcadores iniciales al construir la pantalla.
    _setMarkers();
  }

  /// Simula la carga de marcadores en el mapa.
  /// En una app real, estos datos vendrían de una API.
  void _setMarkers() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('movil_en_ruta_1'),
          position:
              const LatLng(-32.449, -71.241), // Ubicación cerca de La Ligua
          // TODO: Reemplazar con tu ícono de marcador personalizado.
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('movil_en_ruta_2'),
          position: const LatLng(-32.683, -71.433), // Ubicación cerca de Papudo
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('alerta_detenido'),
          position:
              const LatLng(-32.84, -71.45), // Ubicación cerca de Puchuncaví
          // TODO: Reemplazar con tu ícono de marcador de alerta.
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Se añade el Drawer (menú lateral) personalizado.
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Capa 0: El mapa de Google.
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              // Completa el controlador del mapa cuando el mapa esté listo.
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Capa 1: Barra de búsqueda y elementos superiores.
          _buildTopSearchBar(),

          // Capa 2: Botones de acción flotantes en la esquina inferior derecha.
          _buildFloatingActionButtons(),
        ],
      ),
    );
  }

  /// Construye la barra de búsqueda superior con el botón de menú y el avatar.
  Widget _buildTopSearchBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // El Builder proporciona el BuildContext correcto para encontrar el Scaffold.
            Builder(builder: (context) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 5, color: Colors.black.withOpacity(0.2))
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black54),
                      onPressed: () {
                        // Abre el Drawer al presionar el botón de menú.
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2)),
                      ),
                      child: const Text('3',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 5, color: Colors.black.withOpacity(0.2))
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar un móvil',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon:
                        const Icon(Icons.filter_list, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // TODO: Reemplazar con la imagen del usuario real.
            _buildDriverInfo()
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      constraints: BoxConstraints(maxWidth: 200), // Limita el ancho máximo
      child: Row(
        mainAxisSize: MainAxisSize.min, // Evita que se expanda infinitamente
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  /// Construye la columna de botones flotantes para el zoom y la navegación.
  Widget _buildFloatingActionButtons() {
    return Positioned(
      bottom: 30,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            onPressed: () async {
              final controller = await _mapController.future;
              controller.animateCamera(CameraUpdate.zoomIn());
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            onPressed: () async {
              final controller = await _mapController.future;
              controller.animateCamera(CameraUpdate.zoomOut());
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.remove, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "recenter",
            onPressed: () {
              // TODO: Añadir lógica para centrar el mapa o activar navegación.
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.navigation_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
