import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

// Importaciones de la aplicación
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart';
import 'package:wisetrack_app/data/models/vehicles/VehiclePositionModel.dart'; 
import 'package:wisetrack_app/data/services/VehicleServicePosition.dart';
import 'package:wisetrack_app/data/services/auth_api_service.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/AppDrawer.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/FilterBottomSheet.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/VehicleDetailScreen.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/ui/profile/EditProfileScreen.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';
import 'package:wisetrack_app/utils/TokenStorage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  // --- Controladores del Mapa y Marcadores ---
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  
  // --- Estado de Carga y Animación ---
  bool _isLoading = true;
  late AnimationController _animationController;

  // --- Estado para la funcionalidad de Búsqueda ---
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _filteredVehicles = [];
  Map<String, LatLng> _vehiclePositions = {};
  Map<int, String> _vehicleTypeMap = {};
    Position? _lastKnownPosition;
  static const double _locationChangeThreshold = 50.0;
  Set<String> _currentFilters = {}; 
  Set<Marker> _allMarkers = {};  
  Set<Marker> _visibleMarkers = {};  

  bool _isLoggingOut = false;  

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

 

    _searchFocusNode.addListener(_onSearchFocusChange);
    _searchController.addListener(_filterVehicles);

    _initializeDashboardData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermissionAndAnimate();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }


Future<void> _handleInvalidToken() async {
  // Mostramos un mensaje al usuario
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Tu sesión ha expirado. Por favor, inicia sesión de nuevo.'),
      backgroundColor: Colors.orange,
    ),
  );
  
  // Borramos el token inválido del almacenamiento
  await TokenStorage.deleteToken();

  // Esperamos un momento para que el usuario vea el mensaje
  await Future.delayed(const Duration(seconds: 2));

  // Redirigimos al login y limpiamos todas las pantallas anteriores
  if (mounted) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

  /// Inicializa todos los datos del dashboard en paralelo para máxima eficiencia.
  Future<void> _initializeDashboardData() async {
    setState(() => _isLoading = true);
    _animationController.repeat();

    try {
      final results = await Future.wait([
        VehicleService.getAllVehicles(),
        VehiclePositionService.getVehiclesPositions(),
        VehicleService.getVehicleTypes(),
      ]);

      final List<Vehicle> vehicles = results[0] as List<Vehicle>;
      final VehiclePositionResponse positionResponse = results[1] as VehiclePositionResponse;
      final List<VehicleType> types = results[2] as List<VehicleType>;

      final Map<int, String> typesMap = {for (var type in types) type.id: type.name};
      _setupMarkers(positionResponse.data);

      if(mounted) {
        setState(() {
          _allVehicles = vehicles;
          _vehicleTypeMap = typesMap;
          _filteredVehicles = List.from(_allVehicles);
        });
      }

     } catch (e) {
    print('Error al inicializar datos del dashboard: $e');

    // --- LÓGICA CLAVE PARA MANEJAR EL ERROR 401 ---
    if (e.toString().contains('401')) {
      if (mounted) {
        _handleInvalidToken();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar los datos: $e')),
        );
      }
    }
  } finally {
    if (mounted && !_isLoggingOut) { // _isLoggingOut es la variable que tenías para el logout
      setState(() => _isLoading = false);
      _animationController.stop();
      _animationController.reset();
    }
  }
}
  /// Procesa las posiciones de los vehículos y las convierte en marcadores.
  void _setupMarkers(List<VehicleCurrentPosition> positions) {
      final Map<String, LatLng> positionsMap = {};
      final Set<Marker> vehicleMarkers = positions.map((position) {
        final latLng = LatLng(position.latitude, position.longitude);
        positionsMap[position.vehiclePlate] = latLng;
        return Marker(
          markerId: MarkerId(position.vehiclePlate),
          position: latLng,
          infoWindow: InfoWindow(
            title: position.vehiclePlate,
            snippet: 'Velocidad: ${position.speed.toStringAsFixed(1)} km/h',
            onTap: () { // El tap en la ventana de información también navega
              _navigateToDetail(position.vehiclePlate);
            }
          ),
          icon: _getMarkerIcon(position.ignitionStatus),
          onTap: () { // El tap en el marcador navega a detalles
            _navigateToDetail(position.vehiclePlate);
          }
        );
      }).toSet();
      
      setState(() {
        _markers.removeWhere((m) => m.markerId.value != 'user_location');
        _markers.addAll(vehicleMarkers);
        _vehiclePositions = positionsMap;
      });
  }

  /// Filtra la lista de vehículos basado en el texto del buscador.
  void _filterVehicles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredVehicles = List.from(_allVehicles);
      } else {
        _filteredVehicles = _allVehicles.where((vehicle) {
          final typeName = _vehicleTypeMap[vehicle.vehicleType]?.toLowerCase() ?? '';
          return vehicle.plate.toLowerCase().contains(query) || typeName.contains(query);
        }).toList();
      }
    });
  }

  /// Acción al seleccionar un vehículo de la lista de búsqueda.
  void _onVehicleSelected(Vehicle vehicle) {
    _navigateToDetail(vehicle.plate);
  }

  /// Navega a la pantalla de detalles de un vehículo.
  void _navigateToDetail(String plate) {
    // Primero, oculta el teclado y la lista de búsqueda para una transición limpia
    _searchFocusNode.unfocus();
    _searchController.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetailScreen(plate: plate),
      ),
    );
  }

  /// Devuelve un ícono de color diferente según el estado del motor.
  BitmapDescriptor _getMarkerIcon(bool isIgnitionOn) {
    return BitmapDescriptor.defaultMarkerWithHue(
      isIgnitionOn ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
    );
  }

  /// Devuelve el IconData apropiado para el nombre del tipo de vehículo.
  IconData _getIconForVehicleType(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'tracto': return Icons.local_shipping;
      case 'camion 3/4': return Icons.local_shipping;
      case 'rampla seca': return Icons.fire_truck_sharp;
      case 'liviano': return Icons.directions_car;
      case 'liviano frio': return Icons.ac_unit;
      case 'cama baja': return Icons.airport_shuttle;
      case 'otro': return Icons.help_outline;
      default: return Icons.help_outline;
    }
  }


  /// Filtra la lista de vehículos Y los marcadores del mapa.
  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    
    // 1. Filtra la lista de vehículos para la búsqueda
    final filteredVehicles = _allVehicles.where((vehicle) {
      final vehicleTypeName = _vehicleTypeMap[vehicle.vehicleType] ?? '';
      
      final matchesSearchQuery = vehicle.plate.toLowerCase().contains(query) || vehicleTypeName.toLowerCase().contains(query);

      if (_currentFilters.isEmpty) return matchesSearchQuery;

      final typeMatches = !_currentFilters.any((f) => _vehicleTypeMap.values.contains(f)) || _currentFilters.contains(vehicleTypeName);
      final connectionMatches = !_currentFilters.contains('Online') && !_currentFilters.contains('Offline') ||
                                (_currentFilters.contains('Online') && vehicle.statusDevice == 1) ||
                                (_currentFilters.contains('Offline') && vehicle.statusDevice == 0);
      final engineStatusMatches = !_currentFilters.contains('Encendido') && !_currentFilters.contains('Apagado') ||
                                  (_currentFilters.contains('Encendido') && vehicle.statusVehicle == 1) ||
                                  (_currentFilters.contains('Apagado') && vehicle.statusVehicle == 0);

      return matchesSearchQuery && typeMatches && connectionMatches && engineStatusMatches;
    }).toList();

    // 2. Filtra los marcadores del mapa
    final Set<String> filteredPlates = filteredVehicles.map((v) => v.plate).toSet();
    final Set<Marker> visibleMarkers = _allMarkers.where((marker) {
      return marker.markerId.value == 'user_location' || filteredPlates.contains(marker.markerId.value);
    }).toSet();

    // 3. Actualiza el estado
    setState(() {
      _filteredVehicles = filteredVehicles;
      _visibleMarkers = visibleMarkers;
    });
  }


  /// Maneja el cambio de foco en el campo de búsqueda.
  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          drawer: AppDrawer(onLogout: _logout),
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: const CameraPosition(target: LatLng(-32.775, -71.229), zoom: 11.0),
                onMapCreated: (GoogleMapController controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onTap: (_) => _searchFocusNode.unfocus(),
              ),
              if (!_isLoading) _buildTopSearchBar(),
              if (!_isLoading) _buildFloatingActionButtons(),
            ],
          ),
        ),
if (_isLoading || _isLoggingOut) // Agrega _isLoggingOut aquí
          Positioned.fill(
            child: AnimatedTruckProgress(animation: _animationController),
          ),
      ],
    );
  }

  Widget _buildTopSearchBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Builder(builder: (context) {
                  return Container(
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.2))]),
                    child: IconButton(icon: const Icon(Icons.menu, color: Colors.black54), onPressed: () => Scaffold.of(context).openDrawer()),
                  );
                }),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.2))]),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Buscar un móvil',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _openFilterBottomSheet();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Transform.scale(scale: 0.7, child: ImageIcon(const AssetImage('assets/images/icon_filter.png'), color: AppColors.primary)),
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(left: 20),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildDriverInfo(),
              ],
            ),
            _buildSearchResultsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    if (!_isSearchFocused || _filteredVehicles.isEmpty) {
      return const SizedBox.shrink();
    }
    const double itemHeight = 54.0;
    final int displayItemCount = _filteredVehicles.length > 5 ? 5 : _filteredVehicles.length;
    final double containerHeight = displayItemCount * itemHeight;

    return Container(
      margin: const EdgeInsets.only(top: 10.0, left: 56.0, right: 56.0),
      height: containerHeight,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.15))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: _filteredVehicles.length,
          itemBuilder: (context, index) {
            final vehicle = _filteredVehicles[index];
            final String vehicleTypeName = _vehicleTypeMap[vehicle.vehicleType] ?? 'Desconocido';
            final IconData vehicleIcon = _getIconForVehicleType(vehicleTypeName);

            return ListTile(
              leading: SizedBox(width: 40, height: 40, child: Center(child: Icon(vehicleIcon, size: 24, color: AppColors.primary))),
              title: Text(vehicle.plate),
               onTap: () => _onVehicleSelected(vehicle),
              dense: true,
            );
          },
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
        ),
      ),
    );
  }   
 
 Future<void> _logout() async {
  if (_isLoggingOut) return; // Evita múltiples llamadas

  setState(() => _isLoggingOut = true);
  _animationController.repeat(); // Inicia la animación

  try {
    // 1. Ejecutar el logout en el backend
    final logoutResponse = await AuthService.logout();

    // 2. Mostrar feedback al usuario según la respuesta
    if (logoutResponse.detail == null || logoutResponse.detail!.contains('Error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(logoutResponse.detail ?? 'Error desconocido al cerrar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error durante el logout: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    // Asegurarse de eliminar el token incluso si falla el logout
    await TokenStorage.deleteToken();

    // Detener y resetear la animación
    _animationController.stop();
    _animationController.reset();

    if (mounted) {
      setState(() => _isLoggingOut = false);
    }

    // Navegar al login de todas formas
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }
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


  Widget _buildDriverInfo() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
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
    /// Abre el BottomSheet y aplica los filtros seleccionados.
  void _openFilterBottomSheet() async {
    _searchFocusNode.unfocus(); // Cierra el teclado si está abierto
    final Set<String>? newFilters = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return FilterBottomSheet(initialFilters: _currentFilters);
                },
              );

    if (newFilters != null && mounted) {
      setState(() {
        _currentFilters = newFilters;
        _applyFilters(); // Vuelve a aplicar todos los filtros
      });
    }
  }



 Widget _buildFloatingActionButtons() {
  return Positioned(
    bottom: 30,
    right: 16,
    child: Column(
      children: [
        GestureDetector(
          onTap: () async {
            final controller = await _mapController.future;
            controller.animateCamera(CameraUpdate.zoomIn());
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondoFloating.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/mas.png',
                width: 20,
                height: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final controller = await _mapController.future;
            controller.animateCamera(CameraUpdate.zoomOut());
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondoFloating.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/menos.png',
                width: 20,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _requestLocationPermissionAndAnimate,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondoFloating.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/gps.png',
                width: 20,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}