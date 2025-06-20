import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisetrack_app/ui/MenuPage/AppDrawer.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/FilterBottomSheet.dart';
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

  Position? _lastKnownPosition;
  // Distancia mínima (en metros) para considerar un cambio de ubicación.
  static const double _locationChangeThreshold = 50.0;

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
    // Solicita el permiso de ubicación y anima el mapa al cargar la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermissionAndAnimate();
    });
  }

  Future<void> _requestLocationPermissionAndAnimate() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      try {
        Position newPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // --- INICIO DE LA LÓGICA DE CACHÉ ---

        bool hasMovedSignificantly = true; // Asumimos que sí por defecto.

        if (_lastKnownPosition != null) {
          // Calcula la distancia entre la nueva posición y la última guardada.
          final distanceInMeters = Geolocator.distanceBetween(
            _lastKnownPosition!.latitude,
            _lastKnownPosition!.longitude,
            newPosition.latitude,
            newPosition.longitude,
          );

          print(
              "Distancia desde la última posición: ${distanceInMeters.toStringAsFixed(2)} metros.");

          // Si la distancia es menor que nuestro umbral, no hacemos nada.
          if (distanceInMeters < _locationChangeThreshold) {
            hasMovedSignificantly = false;
            print(
                "El usuario no se ha movido lo suficiente. No se animará el mapa.");
          }
        }

        // Solo animamos la cámara si es la primera vez o si se ha movido lo suficiente.
        if (hasMovedSignificantly) {
          print("Actualizando la vista del mapa a la nueva ubicación.");

          final GoogleMapController controller = await _mapController.future;
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(newPosition.latitude, newPosition.longitude),
                zoom: 15.0,
              ),
            ),
          );

          // Actualizamos la última posición conocida.
          setState(() {
            _lastKnownPosition = newPosition;
          });
        }
        // --- FIN DE LA LÓGICA DE CACHÉ ---

        // El marcador de ubicación del usuario se actualiza siempre.
        _updateUserLocationMarker(newPosition);
      } catch (e) {
        print("Error al obtener la ubicación: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No se pudo obtener la ubicación. Asegúrate de que tu GPS esté activado.'),
            ),
          );
        }
      }
    } else {
      print("Permiso de ubicación denegado.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'El permiso de ubicación es necesario para usar esta función.'),
          ),
        );
      }
    }
  }

  /// Actualiza o añade el marcador de la ubicación actual del usuario.
  void _updateUserLocationMarker(Position position) {
    setState(() {
      // Primero, removemos el marcador anterior si existe.
      _markers
          .removeWhere((m) => m.markerId == const MarkerId('user_location'));
      // Luego, añadimos el nuevo.
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  /// Simula la carga de marcadores en el mapa.
  void _setMarkers() {
    setState(() {
      _markers.addAll([
        Marker(
          markerId: const MarkerId('movil_en_ruta_1'),
          position:
              const LatLng(-32.449, -71.241), // Ubicación cerca de La Ligua
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
        Marker(
          markerId: const MarkerId('movil_en_ruta_2'),
          position: const LatLng(-32.683, -71.433), // Ubicación cerca de Papudo
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
        Marker(
          markerId: const MarkerId('alerta_detenido'),
          position:
              const LatLng(-32.84, -71.45), // Ubicación cerca de Puchuncaví
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            myLocationEnabled:
                true, // Muestra el punto azul de la ubicación actual
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
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.2)),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black54),
                      onPressed: () {
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
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                        blurRadius: 5, color: Colors.black.withOpacity(0.2)),
                  ],
                ),
                // ... tu código ...

                child: TextField(
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Buscar un móvil',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.black),

                    // --- INICIO DE LA MODIFICACIÓN ---
                    suffixIcon: GestureDetector(
                      onTap: () {
                        /*
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return const FilterBottomSheet();
                          },
                        );*/
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Transform.scale(
                          scale:
                              0.7, // Escala el ícono al 70% de su tamaño original
                          child: ImageIcon(
                            const AssetImage('assets/images/icon_filter.png'),
                            color: AppColors.primary,
                            size: 10, // Usa el tamaño original
                          ),
                        ),
                      ),
                    ),
                    // --- FIN DE LA MODIFICACIÓN ---

                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildDriverInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
              _requestLocationPermissionAndAnimate();
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.navigation_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
