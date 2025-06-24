import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/FilterBottomSheet.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/VehicleDetailScreen.dart';
// import 'package:wisetrack_app/ui/MenuPage/moviles/VehicleDetailScreen.dart'; // Descomenta si lo necesitas
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';

class MobilesScreen extends StatefulWidget {
  const MobilesScreen({Key? key}) : super(key: key);

  @override
  _MobilesScreenState createState() => _MobilesScreenState();
}

class _MobilesScreenState extends State<MobilesScreen>
    with SingleTickerProviderStateMixin {
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _displayedVehicles = [];

  Map<int, String> _vehicleTypeMap = {};

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
        duration:
            const Duration(seconds: 5) // Duración de un ciclo de animación
        );
    _fetchInitialData();
    ();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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

      final Map<int, String> typesMap = {
        for (var type in types) type.id: type.name
      };

      await _animationController.forward(from: _animationController.value);
      _animationController.stop();

      if (mounted) {
        setState(() {
          _allVehicles = vehicles;
          _vehicleTypeMap = typesMap;
          _applyFilters(); // Aplicamos filtros iniciales
        });
        // Añadimos el listener DESPUÉS de la carga inicial.
        _searchController.addListener(_applyFilters);
      }
    } catch (e) {
      if (mounted) {
        _animationController.stop();
        setState(() {
          _errorMessage = "Error al cargar los móviles. Revisa tu conexión.";
          debugPrint('Error al cargar datos iniciales: $e');
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

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _animationController.repeat();

    try {
      // Ejecutamos ambas llamadas a la API en paralelo para más eficiencia
      final results = await Future.wait([
        VehicleService.getAllVehicles(),
        VehicleService.getVehicleTypes(),
      ]);

      // Extraemos los resultados
      final List<Vehicle> vehicles = results[0] as List<Vehicle>;
      final List<VehicleType> types = results[1] as List<VehicleType>;

      // Creamos el mapa de tipos para búsquedas rápidas
      final Map<int, String> typesMap = {
        for (var type in types) type.id: type.name
      };

      await _animationController.forward(from: _animationController.value);
      _animationController.stop();

      if (mounted) {
        setState(() {
          _allVehicles = vehicles;
          _vehicleTypeMap = typesMap; // Guardamos el mapa de tipos
          _applyFilters();
        });
        _searchController.addListener(_applyFilters);
      }
    } catch (e) {
      if (mounted) {
        _animationController.stop();
        setState(() {
          _errorMessage = "Error al cargar los móviles. Revisa tu conexión.";
          debugPrint('Error al cargar datos iniciales: $e');
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

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    _displayedVehicles = _allVehicles.where((vehicle) {
      final vehicleTypeName = _vehicleTypeMap[vehicle.vehicleType] ?? '';

      // 1. Filtro por texto de búsqueda (patente o tipo)
      final matchesSearchQuery = vehicle.plate.toLowerCase().contains(query) ||
          vehicleTypeName.toLowerCase().contains(query);

      // Si no hay filtros de chips, solo importa la búsqueda
      if (_currentFilters.isEmpty) {
        return matchesSearchQuery;
      }

      // 2. Lógica de filtrado por chips (ahora dinámica)
      // Esta lógica revisa si un tipo de filtro está activo, y si lo está, si el vehículo cumple la condición.

      final typeFilters = _currentFilters
          .where((f) => _vehicleTypeMap.values.contains(f))
          .toSet();
      final bool typeMatches =
          typeFilters.isEmpty || typeFilters.contains(vehicleTypeName);

      final connectionFilters = _currentFilters
          .where((f) => ['Online', 'Offline'].contains(f))
          .toSet();
      final bool connectionMatches = connectionFilters.isEmpty ||
          (connectionFilters.contains('Online') && vehicle.statusDevice == 1) ||
          (connectionFilters.contains('Offline') && vehicle.statusDevice == 0);

      // Añadimos la lógica para los otros filtros que tienes en el BottomSheet
      final positionFilters = _currentFilters
          .where((f) => ['Válida', 'Inválida'].contains(f))
          .toSet();
      final bool positionMatches = positionFilters.isEmpty ||
          (positionFilters.contains('Válida') &&
              vehicle.statusVehicle ==
                  1) || // Asumiendo que statusVehicle indica la posición
          (positionFilters.contains('Inválida') && vehicle.statusVehicle == 0);

      final engineStatusFilters = _currentFilters
          .where((f) => ['Encendido', 'Apagado'].contains(f))
          .toSet();
      final bool engineStatusMatches = engineStatusFilters.isEmpty ||
          (engineStatusFilters.contains('Encendido') &&
              vehicle.statusVehicle == 1) ||
          (engineStatusFilters.contains('Apagado') &&
              vehicle.statusVehicle == 0);

      // El vehículo debe cumplir con la búsqueda Y con todos los filtros de chips activos
      return matchesSearchQuery &&
          typeMatches &&
          connectionMatches &&
          positionMatches &&
          engineStatusMatches;
    }).toList();

    setState(() {}); // Actualiza la UI con la lista filtrada
  }

  // --- LÓGICA DE CARGA REFINADA ---
  Future<void> _loadVehiclesAndSetupFiltering() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Inicia la animación en bucle
    _animationController.repeat();

    try {
      final vehicles = await VehicleService.getAllVehicles();

      // Detiene el bucle y completa la animación
      await _animationController.forward(from: _animationController.value);
      _animationController.stop();

      if (mounted) {
        setState(() {
          _allVehicles = vehicles;
          _applyFilters();
        });
        _searchController.addListener(_applyFilters);
      }
    } catch (e) {
      if (mounted) {
        _animationController.stop(); // Detiene la animación en caso de error
        setState(() {
          _errorMessage = "Error al cargar los móviles. Revisa tu conexión.";
          debugPrint('Error al cargar vehículos: $e');
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

  IconData _getIconForVehicleType(String typeName) {
    // Mapeo de nombres (del API) a íconos. ¡Mucho más flexible!
    switch (typeName.toLowerCase()) {
      case 'tracto':
        return Icons.local_shipping;
      case 'camion 3/4':
        return Icons.local_shipping;
      case 'rampla seca':
        return Icons.fire_truck_sharp; // Ícono de ejemplo
      case 'liviano':
        return Icons.directions_car;
      case 'liviano frio':
        return Icons.ac_unit;
      case 'cama baja':
        return Icons.airport_shuttle; // Ícono de ejemplo
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _refreshVehicles() async {
    _searchController.removeListener(_applyFilters);
    _searchController.clear(); // Limpiamos la búsqueda al refrescar
    await _fetchInitialData(); // Reutilizamos el método de carga principal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        // Usamos un Stack para poder poner el overlay de carga encima del contenido
        children: [
          // Contenido principal de la pantalla
          Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: _buildBodyContent(),
              ),
            ],
          ),
          // --- INDICADOR DE CARGA CENTRALIZADO Y DINÁMICO ---
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
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshVehicles,
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Reintentar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (!_isLoading && _displayedVehicles.isEmpty) {
      return Center(
          child: Text(_searchController.text.isEmpty
              ? 'No hay vehículos para mostrar.'
              : 'No se encontraron resultados.'));
    }
    return _isLoading
        ? const SizedBox.shrink()
        : ListView.separated(
            itemCount: _displayedVehicles.length,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemBuilder: (context, index) {
              final vehicle = _displayedVehicles[index];
              return _buildVehicleTile(vehicle, context);
            },
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
              // CORRECCIÓN: Añade un margen izquierdo para que el divisor se alinee con el texto.
              // 72.0 es un buen valor que usualmente cubre el ícono y el padding.
              indent: 12.0,
              // Opcional: Un pequeño margen derecho también mejora la estética.
              endIndent: 16.0,
            ),
          );
  }

  // Se extrajo la AppBar para mayor claridad
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
                child: Image.asset(
                  'assets/images/backbtn.png',
                  width: 40,
                  height: 40,
                ),
              ),
              const Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Móviles',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40), // Para balancear el botón de regreso
            ],
          ),
        ),
      ),
    );
  }

  // --- El resto de tus widgets no necesitan cambios ---
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar un móvil por patente',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
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
  bool isShieldActive = false; // Replace with actual logic if available

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vehicle type icon
          CircleAvatar(
            backgroundColor: iconBgColor,
            child: Icon(vehicleIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          // Vehicle details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vehicle.plate,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
          // Status icons
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
