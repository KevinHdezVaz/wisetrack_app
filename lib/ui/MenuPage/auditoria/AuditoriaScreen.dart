import 'package:flutter/material.dart';
 import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/FilterBottomSheet.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/VehicleDetailScreen.dart';
// Asegúrate de tener una pantalla de detalles para auditoría, aquí un placeholder.
// import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditDetailsScreen.dart'; 
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';

class Auditoriascreen extends StatefulWidget {
  const Auditoriascreen({Key? key}) : super(key: key);

  @override
  _AuditoriascreenState createState() => _AuditoriascreenState();
}

class _AuditoriascreenState extends State<Auditoriascreen> with SingleTickerProviderStateMixin {
  // --- Listas de datos ---
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _displayedVehicles = [];
  // Mapa para guardar los tipos de vehículo (id -> nombre)
  Map<int, String> _vehicleTypeMap = {};

  // --- Estado de la UI ---
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  Set<String> _currentFilters = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    // Llamamos al método de carga unificado
    _fetchInitialData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Carga todos los datos necesarios (vehículos y tipos) en paralelo.
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    _animationController.repeat();

    try {
      final results = await Future.wait([
        VehicleService.getAllVehicles(),
        VehicleService.getVehicleTypes(),
      ]);

      final List<Vehicle> vehicles = results[0] as List<Vehicle>;
      final List<VehicleType> types = results[1] as List<VehicleType>;

      final Map<int, String> typesMap = {for (var type in types) type.id: type.name};
      
      await _animationController.forward(from: _animationController.value);
      _animationController.stop();

      if (mounted) {
        setState(() {
          _allVehicles = vehicles;
          _vehicleTypeMap = typesMap;
          _applyFilters();
        });
        _searchController.addListener(_applyFilters);
      }
    } catch (e) {
      if (mounted) {
        _animationController.stop();
        setState(() {
          _errorMessage = "Error al cargar los datos. Revisa tu conexión.";
          debugPrint('Error al cargar datos iniciales para auditoría: $e');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.reset();
      }
    }
  }

  /// Aplica los filtros de búsqueda y de chips a la lista de vehículos.
  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    
    _displayedVehicles = _allVehicles.where((vehicle) {
      final vehicleTypeName = _vehicleTypeMap[vehicle.vehicleType]?.toLowerCase() ?? '';

      // Filtro por texto de búsqueda (patente o tipo)
      final matchesSearchQuery = vehicle.plate.toLowerCase().contains(query) || 
                                 vehicleTypeName.contains(query);

      if (_currentFilters.isEmpty) {
        return matchesSearchQuery;
      }

      // Lógica de filtrado por chips (ahora dinámica)
      bool typeMatches = !_currentFilters.any((f) => _vehicleTypeMap.values.any((v) => v.toLowerCase() == f.toLowerCase())) || 
                         _currentFilters.contains(_vehicleTypeMap[vehicle.vehicleType]);
      
      bool positionMatches = !_currentFilters.any((f) => ['Válida', 'Inválida'].contains(f)) ||
                             (_currentFilters.contains('Válida') && vehicle.statusVehicle == 1) ||
                             (_currentFilters.contains('Inválida') && vehicle.statusVehicle == 0);

      bool connectionMatches = !_currentFilters.any((f) => ['Online', 'Offline'].contains(f)) ||
                               (_currentFilters.contains('Online') && vehicle.statusDevice == 1) ||
                               (_currentFilters.contains('Offline') && vehicle.statusDevice == 0);

      bool engineStatusMatches = !_currentFilters.any((f) => ['Encendido', 'Apagado'].contains(f)) ||
                                 (_currentFilters.contains('Encendido') && vehicle.statusVehicle == 1) ||
                                 (_currentFilters.contains('Apagado') && vehicle.statusVehicle == 0);

      return matchesSearchQuery && typeMatches && positionMatches && connectionMatches && engineStatusMatches;
    }).toList();
    
    setState(() {}); // Actualiza la UI con la lista filtrada
  }

  /// Devuelve el ícono correspondiente al nombre del tipo de vehículo.
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

  Future<void> _refreshVehicles() async {
    _searchController.removeListener(_applyFilters);
    _currentFilters = {};
    _searchController.clear();
    await _fetchInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: _buildBodyContent(),
              ),
            ],
          ),
          if (_isLoading)
            Center(
              child: AnimatedTruckProgress(
                animation: _animationController,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshVehicles,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (!_isLoading && _displayedVehicles.isEmpty) {
      return Center(child: Text(_searchController.text.isEmpty && _currentFilters.isEmpty ? 'No hay vehículos para mostrar.' : 'No se encontraron resultados.'));
    }
    return _isLoading ? const SizedBox.shrink() : ListView.separated(
      itemCount: _displayedVehicles.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final vehicle = _displayedVehicles[index];
        return _buildVehicleTile(vehicle, context);
      },
// En el método _buildBodyContent, dentro del ListView.separated...

separatorBuilder: (context, index) => Divider(
  height: 1,
  thickness: 1,
  color: Colors.grey.shade200,
  // CORRECCIÓN: Añade un margen izquierdo para que el divisor se alinee con el texto.
  // 72.0 es un buen valor que usualmente cubre el ícono y el padding.
  indent: 72.0,
  // Opcional: Un pequeño margen derecho también mejora la estética.
  endIndent: 16.0,
),    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
              ),
              const Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Auditorías', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(width: 8),
                      Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar un móvil para auditar',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: GestureDetector(
            onTap: () async {
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
                  _applyFilters();
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: ImageIcon(
                const AssetImage('assets/images/icon_filter.png'),
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTile(Vehicle vehicle, BuildContext context) {
  final String vehicleTypeName = _vehicleTypeMap[vehicle.vehicleType] ?? 'Desconocido';
  final IconData vehicleIcon = _getIconForVehicleType(vehicleTypeName);
  Color iconBgColor = vehicle.statusDevice == 1
      ? AppColors.primary.withOpacity(0.8)
      : Colors.red.shade400;

  bool isLocationActive = vehicle.statusVehicle == 1;
  bool isGpsActive = vehicle.statusDevice == 1;
  bool isKeyActive = false; // Replace with actual logic if available

  // Usamos InkWell para hacer toda la fila tappable, como un ListTile
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleDetailScreen(plate: vehicle.plate),
        ),
      );
    },
    child: Padding(
      // Padding general para la fila
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Row(
        // CORRECCIÓN: Esta es la propiedad clave para centrar todo verticalmente
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Ícono a la izquierda (sin cambios)
          CircleAvatar(
            backgroundColor: iconBgColor,
            child: Icon(vehicleIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16), // Espacio entre ícono y texto

          // 2. Columna para el texto (ocupa el espacio disponible)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido de la columna
              children: [
                Text(
                  vehicle.plate,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                
               
              ],
            ),
          ),
          
          // 3. Íconos a la derecha (sin cambios)
         Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statusIcon('ubi', isLocationActive),
              _statusIcon('gps', isGpsActive),
              _statusIcon('llave', isKeyActive),
        //      _statusIcon('shield', isShieldActive),
            ],
          ),
        ],
      ),
    ),
  );
}

 Widget _statusIcon(String baseName, bool isActive) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Image.asset(
      'assets/images/${baseName}_${isActive ? 'on' : 'off'}.png',
      width: 23.0,
      height: 23.0,
    ),
  );
}
}