import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

// Importaciones de la aplicación (Corregidas para consistencia)
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart';
import 'package:wisetrack_app/data/models/vehicles/VehiclePositionModel.dart'; 
import 'package:wisetrack_app/data/services/VehicleServicePosition.dart';
import 'package:wisetrack_app/data/services/auth_api_service.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/AppDrawer.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/ui/profile/EditProfileScreen.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  // --- Controladores del Mapa y Marcadores ---
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  Position? _lastKnownPosition;
  
  // --- Estado de Carga y Animación ---
  bool _isLoading = false;
  late AnimationController _animationController;

  // --- Estado para la funcionalidad de Búsqueda ---
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _filteredVehicles = [];
  Map<String, LatLng> _vehiclePositions = {};

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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

  /// Inicializa los datos del dashboard en el orden deseado.
  Future<void> _initializeDashboardData() async {
    // CORREGIDO: Se asegura que la llamada ligera se ejecute primero.
    await _fetchVehicleListForSearch();
    await _fetchAndSetVehicleMarkers();
  }

  /// Obtiene la lista completa de vehículos para usar en la búsqueda.
  Future<void> _fetchVehicleListForSearch() async {
    try {
      _allVehicles = await VehicleService.getAllVehicles();
      setState(() {
        // CAMBIO 1: Ahora, inicialmente, la lista filtrada contiene TODOS los vehículos.
        _filteredVehicles = List.from(_allVehicles);
      });
    } catch (e) {
      print('Error al obtener la lista de vehículos para búsqueda: $e');
    }
  }

  /// Filtra la lista de vehículos basado en el texto del buscador.
  void _filterVehicles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // CAMBIO 2: Si la búsqueda está vacía, la lista filtrada vuelve a ser la lista completa.
        _filteredVehicles = List.from(_allVehicles);
      } else {
        _filteredVehicles = _allVehicles
            .where((vehicle) => vehicle.plate.toLowerCase().contains(query))
            .toList();
      }
    });
  }
  
  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  void _onVehicleSelected(Vehicle vehicle) async {
    _searchFocusNode.unfocus();
    _searchController.clear();

    final position = _vehiclePositions[vehicle.plate];
    if (position != null) {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 16.0),
        ),
      );
    }
  }

  Future<void> _fetchAndSetVehicleMarkers() async {
    try {
      // CORREGIDO: El nombre del método era getVehiclesPositions
      final VehiclePositionResponse response = await VehiclePositionService.getAllVehiclesPosition();
      if (response.data.isEmpty) return;

      final Map<String, LatLng> positionsMap = {};
      final Set<Marker> vehicleMarkers = response.data.map((position) {
        final latLng = LatLng(position.latitude, position.longitude);
        positionsMap[position.vehiclePlate] = latLng;
        return Marker(
          markerId: MarkerId(position.vehiclePlate),
          position: latLng,
          infoWindow: InfoWindow(
            title: position.vehiclePlate,
            snippet: 'Velocidad: ${position.speed.toStringAsFixed(1)} km/h',
          ),
          icon: _getMarkerIcon(position.ignitionStatus),
        );
      }).toSet();
      
      setState(() {
        _markers.removeWhere((m) => m.markerId.value != 'user_location');
        _markers.addAll(vehicleMarkers);
        _vehiclePositions = positionsMap;
      });

    } catch (e) {
      print('Error al obtener los marcadores de vehículos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar los vehículos: $e')),
        );
      }
    }
  }

  BitmapDescriptor _getMarkerIcon(bool isIgnitionOn) {
    return BitmapDescriptor.defaultMarkerWithHue(
      isIgnitionOn ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
    );
  }

  Future<void> _logout() async { /* ... código sin cambios ... */ }
  Future<void> _requestLocationPermissionAndAnimate() async { /* ... código sin cambios ... */ }
  void _updateUserLocationMarker(Position position) { /* ... código sin cambios ... */ }

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
              _buildTopSearchBar(),
              _buildFloatingActionButtons(),
            ],
          ),
        ),
        
        if (_isLoading)
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.2))],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black54),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  );
                }),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.2))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Buscar un móvil',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Transform.scale(
                              scale: 0.7,
                              child: ImageIcon(
                                const AssetImage('assets/images/icon_filter.png'),
                                color: AppColors.primary,
                              ),
                            ),
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

    // CAMBIO 3: Calculamos una altura fija para el contenedor.
    // Aprox. 50px por cada ListTile 'dense' + 1px por el separador.
    const double itemHeight = 50.0;
    // La altura será para 5 items, o menos si hay menos de 5 vehículos en total.
    final int displayItemCount = _filteredVehicles.length > 5 ? 5 : _filteredVehicles.length;
    final double containerHeight = displayItemCount * itemHeight;


    return Container(
      margin: const EdgeInsets.only(top: 10.0, left: 56.0, right: 56.0),
      // Se establece una altura fija para que la lista de adentro sea scrollable.
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.15))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          // Ya no se necesita shrinkWrap: true porque el contenedor tiene un tamaño fijo.
          // shrinkWrap: true, 
          padding: EdgeInsets.zero,
          itemCount: _filteredVehicles.length,
          itemBuilder: (context, index) {
            final vehicle = _filteredVehicles[index];
            return ListTile(
              leading: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Icon(
                    vehicle.vehicleType.toVehicleTypeEnum().iconData,
              size: 24,
                  
                  ),
                ),
              ),
              title: Text(vehicle.plate),
              onTap: () => _onVehicleSelected(vehicle),
              dense: true,
            );
          },
          separatorBuilder: (context, index) => const Divider(height: 1),
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
            onPressed: _requestLocationPermissionAndAnimate,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.navigation_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}