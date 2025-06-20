import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/FilterBottomSheet.dart';
// import 'package:wisetrack_app/ui/MenuPage/moviles/VehicleDetailScreen.dart'; // Descomenta si lo necesitas
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';

class MobilesScreen extends StatefulWidget {
  const MobilesScreen({Key? key}) : super(key: key);

  @override
  _MobilesScreenState createState() => _MobilesScreenState();
}

class _MobilesScreenState extends State<MobilesScreen> with SingleTickerProviderStateMixin {
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _displayedVehicles = [];
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
        duration: const Duration(seconds: 7) // Duración de un ciclo de animación
    );
    _loadVehiclesAndSetupFiltering();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
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

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<Vehicle> filteredList = _allVehicles.where((vehicle) {
      // Tu lógica de filtrado actual está bien, la mantenemos
      final matchesSearchQuery = vehicle.plate.toLowerCase().contains(query);
      bool matchesChips = true;

      // ... (Aquí va tu lógica compleja de filtrado por chips. No necesita cambios)

      return matchesSearchQuery && matchesChips;
    }).toList();
    
    // Es importante llamar a setState aquí para que la UI se actualice con la lista filtrada
    setState(() {
      _displayedVehicles = filteredList;
    });
  }

  Future<void> _refreshVehicles() async {
    _searchController.removeListener(_applyFilters);
    await _loadVehiclesAndSetupFiltering();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack( // Usamos un Stack para poder poner el overlay de carga encima del contenido
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

  // Se extrajo el contenido del body para mayor claridad en el widget build principal
  Widget _buildBodyContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
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
      return const Center(child: Text('No se encontraron resultados.'));
    }

    // Solo muestra la lista si no está cargando
    return _isLoading ? const SizedBox.shrink() : ListView.separated(
      itemCount: _displayedVehicles.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final vehicle = _displayedVehicles[index];
        return _buildVehicleTile(vehicle, context);
      },
      separatorBuilder: (context, index) => const Divider(
          height: 1, indent: 80, endIndent: 20),
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
    VehicleTypeEnum vehicleTypeEnum = vehicle.vehicleType.toVehicleTypeEnum();
    //String imageAssetPath = vehicleTypeEnum.imageAssetPath;
    

    Color iconBgColor = vehicle.statusDevice == 1
        ? AppColors.primary.withOpacity(0.8)
        : Colors.red.shade400;

    bool isLocationActive = vehicle.statusVehicle == 1;
    bool isGpsActive = vehicle.statusDevice == 1;
    bool isKeyActive = false;
    bool isShieldActive = false;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconBgColor,
        child: Icon(
          
  vehicle.vehicleType.toVehicleTypeEnum().iconData,
                size: 24,
          color: Colors.white,
       
        
        ),
      ),
      title: Text(
        vehicle.plate,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: vehicle.lastReport != null
          ? Text(
              'Último reporte: ${vehicle.lastReport!.toLocal().toIso8601String().substring(0, 16).replaceFirst('T', ' ')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          : const Text('Último reporte: N/A', style: TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _statusIcon(Icons.location_on, isLocationActive),
          _statusIcon(Icons.gps_fixed, isGpsActive),
          _statusIcon(Icons.vpn_key, isKeyActive),
          _statusIcon(Icons.shield, isShieldActive),
        ],
      ),
      onTap: () {
        /*
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailScreen(vehicle: vehicle),
          ),
        );
        */
      },
    );
  }

  Widget _statusIcon(IconData icon, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(
        icon,
        color: isActive ? AppColors.primary : Colors.grey.shade300,
        size: 20,
      ),
    );
  }
}