import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/FilterBottomSheet.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/VehicleDetailScreen.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart'; // Importa tu widget

class MobilesScreen extends StatefulWidget {
  const MobilesScreen({Key? key}) : super(key: key);

  @override
  _MobilesScreenState createState() => _MobilesScreenState();
}

class _MobilesScreenState extends State<MobilesScreen>
    with SingleTickerProviderStateMixin {
  List<Vehicle> _allVehicles = []; // Lista completa de vehículos
  List<Vehicle> _displayedVehicles = []; // Lista que se muestra (filtrada)
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  Set<String> _currentFilters = {}; // Filtros actualmente aplicados
  double _currentProgress = 0.0; // Progreso dinámico
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5)) // Duración estimada inicial
      ..addListener(() {
        setState(() {
          _currentProgress = _animationController.value;
        });
      });
    _loadVehiclesAndSetupFiltering();
  }

  Future<void> _loadVehiclesAndSetupFiltering() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentProgress = 0.0;
      _animationController.reset(); // Reinicia la animación
      _animationController.forward(); // Inicia la animación
    });

    try {
      final vehicles = await VehicleService.getAllVehicles();
      if (mounted) {
        await _animationController.animateTo(1.0,
            duration:
                const Duration(milliseconds: 500)); // Finaliza la animación
        setState(() {
          _allVehicles = vehicles;
          _applyFilters();
          _isLoading = false;
          _currentProgress = 1.0; // Completa el progreso al finalizar
        });
        _searchController.addListener(_applyFilters);
      }
    } catch (e) {
      if (mounted) {
        await _animationController.animateTo(1.0,
            duration:
                const Duration(milliseconds: 500)); // Finaliza en caso de error
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          debugPrint('Error al cargar vehículos: $e');
        });
      }
    }
  }

  // LÓGICA DE FILTRADO COMBINADA (búsqueda por texto + filtros de chip)
  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<Vehicle> filteredList = _allVehicles.where((vehicle) {
      final matchesSearchQuery = vehicle.plate.toLowerCase().contains(query);
      bool matchesChips = true;

      if (_currentFilters.isNotEmpty) {
        final String vehicleTypeLabel =
            vehicle.vehicleType.toVehicleTypeEnum().toString().split('.').last;
        final String statusVehicleLabel =
            vehicle.statusVehicle == 1 ? 'Válida' : 'Inválida';
        final String statusDeviceLabel =
            vehicle.statusDevice == 1 ? 'Online' : 'Offline';

        bool typeMatch = true;
        bool positionMatch = true;
        bool connectionMatch = true;
        bool engineStatusMatch = true;

        if (_currentFilters.any((f) => [
              'Tracto',
              'Rampla seca',
              'Camión 3/4',
              'Liviano',
              'Rampla fría',
              'Cama baja'
            ].contains(f))) {
          typeMatch = _currentFilters.contains(vehicleTypeLabel);
          if (_currentFilters.any((filter) =>
              _getVehicleTypeEnumFromLabel(filter) != null &&
              _getVehicleTypeEnumFromLabel(filter) == VehicleTypeEnum)) {
            typeMatch = true;
          } else if (_currentFilters.any((f) => [
                'Tracto',
                'Rampla seca',
                'Camión 3/4',
                'Liviano',
                'Rampla fría',
                'Cama baja'
              ].contains(f))) {
            typeMatch = false;
          }
        }

        if (_currentFilters.contains('Válida') && vehicle.statusVehicle != 1)
          positionMatch = false;
        if (_currentFilters.contains('Inválida') && vehicle.statusVehicle != 0)
          positionMatch = false;

        if (_currentFilters.contains('Online') && vehicle.statusDevice != 1)
          connectionMatch = false;
        if (_currentFilters.contains('Offline') && vehicle.statusDevice != 0)
          connectionMatch = false;

        if (_currentFilters.contains('Encendido') && vehicle.statusVehicle != 1)
          engineStatusMatch = false;
        if (_currentFilters.contains('Apagado') && vehicle.statusVehicle != 0)
          engineStatusMatch = false;

        matchesChips =
            typeMatch && positionMatch && connectionMatch && engineStatusMatch;
      }

      return matchesSearchQuery && matchesChips;
    }).toList();
    _displayedVehicles = filteredList;
  }

  // Helper para mapear labels de filtro a VehicleTypeEnum
  VehicleTypeEnum? _getVehicleTypeEnumFromLabel(String label) {
    switch (label) {
      case 'Liviano':
        return VehicleTypeEnum.lightVehicle;
      case 'Tracto':
        return VehicleTypeEnum.tracto;
      case 'Rampla seca':
        return VehicleTypeEnum.ramplaSeca;
      case 'Camión 3/4':
        return VehicleTypeEnum.camion3_4;
      case 'Rampla fría':
        return VehicleTypeEnum.ramplaFria;
      case 'Cama baja':
        return VehicleTypeEnum.camaBaja;
      case 'Bus':
        return VehicleTypeEnum.bus;
      case 'Camión':
        return VehicleTypeEnum.truck;
      default:
        return null;
    }
  }

  Future<void> _refreshVehicles() async {
    _searchController.removeListener(_applyFilters);
    await _loadVehiclesAndSetupFiltering();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _animationController.dispose(); // Libera el controlador de animación
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Móviles',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 40),
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage ?? 'Error al cargar los móviles',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _refreshVehicles,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary),
                              child: const Text('Reintentar',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : _displayedVehicles.isEmpty
                        ? const Center(
                            child: Text('No se encontraron resultados.'))
                        : ListView.separated(
                            itemCount: _displayedVehicles.length,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            itemBuilder: (context, index) {
                              final vehicle = _displayedVehicles[index];
                              return _buildVehicleTile(vehicle, context);
                            },
                            separatorBuilder: (context, index) => const Divider(
                                height: 1, indent: 80, endIndent: 20),
                          ),
              ),
            ],
          ),
          if (_isLoading)
            Center(
              child: AnimatedTruckProgress(
                progress:
                    _currentProgress, // Progreso controlado por AnimationController
                duration: const Duration(milliseconds: 400),
              ),
            ), // Indicador de carga como overlay
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar un móvil',
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
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Transform.scale(
                scale: 0.7,
                child: ImageIcon(
                  const AssetImage('assets/images/icon_filter.png'),
                  color: AppColors.primary,
                  size: 10,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTile(Vehicle vehicle, BuildContext context) {
    VehicleTypeEnum vehicleTypeEnum = vehicle.vehicleType.toVehicleTypeEnum();
    String imageAssetPath = vehicleTypeEnum.imageAssetPath;

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
        child: Image.asset(
          imageAssetPath,
          color: Colors.white,
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) {
            debugPrint(
                'Error loading vehicle icon for ${vehicle.plate}: $error');
            return const Icon(Icons.help_outline,
                color: Colors.white, size: 20);
          },
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
          : const Text('Último reporte: N/A',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
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
        /* Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailScreen(vehicle: vehicle),
          ),
        ); */
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
