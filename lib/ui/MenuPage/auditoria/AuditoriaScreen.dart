import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/FilterBottomSheet.dart';
// import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditDetailsScreen.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart'; // 1. Importa la animación

class Auditoriascreen extends StatefulWidget {
  const Auditoriascreen({Key? key}) : super(key: key);

  @override
  _AuditoriascreenState createState() => _AuditoriascreenState();
}

// 2. Añade el TickerProviderStateMixin
class _AuditoriascreenState extends State<Auditoriascreen> with SingleTickerProviderStateMixin {
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _displayedVehicles = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  Set<String> _currentFilters = {};
  
  // 3. Declara el AnimationController
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    // 4. Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    
    _loadVehiclesAndSetupFiltering();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _animationController.dispose(); // 5. Desecha el controlador
    super.dispose();
  }

  // 6. Refina la lógica de carga para incluir la animación
  Future<void> _loadVehiclesAndSetupFiltering() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _animationController.repeat(); // Inicia la animación en bucle

    try {
      final vehicles = await VehicleService.getAllVehicles();
      
      // Detiene el bucle y completa la animación suavemente
      await _animationController.forward(from: _animationController.value);
      _animationController.stop();

      if (mounted) {
        setState(() {
          _allVehicles = vehicles;
          _displayedVehicles = vehicles;
        });
        _searchController.addListener(_applyFilters);
      }
    } catch (e) {
      if (mounted) {
        _animationController.stop(); // Detiene en caso de error
        setState(() {
          _errorMessage = "Error al cargar los móviles. Revisa tu conexión.";
          debugPrint('Error al cargar vehículos para auditoría: $e');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.reset(); // Resetea para la próxima vez
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<Vehicle> filteredList = _allVehicles.where((vehicle) {
      final matchesSearchQuery = vehicle.plate.toLowerCase().contains(query);
      bool matchesChips = true;

      if (_currentFilters.isNotEmpty) {
        // Tu lógica de filtrado de chips (se mantiene como estaba)
        bool typeFilterApplied = false, typeMatches = false;
        bool positionFilterApplied = false, positionMatches = false;
        bool connectionFilterApplied = false, connectionMatches = false;
        bool engineStatusFilterApplied = false, engineStatusMatches = false;

        for (final filterLabel in _currentFilters) {
          final vehicleTypeEnumFromFilter = _getVehicleTypeEnumFromLabel(filterLabel);
          if (vehicleTypeEnumFromFilter != null) {
            typeFilterApplied = true;
            if (vehicle.vehicleType.toVehicleTypeEnum() == vehicleTypeEnumFromFilter) {
              typeMatches = true;
            }
          }
          if (filterLabel == 'Válida') {
            positionFilterApplied = true;
            if (vehicle.statusVehicle == 1) positionMatches = true;
          } else if (filterLabel == 'Inválida') {
            positionFilterApplied = true;
            if (vehicle.statusVehicle == 0) positionMatches = true;
          }
          if (filterLabel == 'Online') {
            connectionFilterApplied = true;
            if (vehicle.statusDevice == 1) connectionMatches = true;
          } else if (filterLabel == 'Offline') {
            connectionFilterApplied = true;
            if (vehicle.statusDevice == 0) connectionMatches = true;
          }
          if (filterLabel == 'Encendido') {
            engineStatusFilterApplied = true;
            if (vehicle.statusVehicle == 1) engineStatusMatches = true;
          } else if (filterLabel == 'Apagado') {
            engineStatusFilterApplied = true;
            if (vehicle.statusVehicle == 0) engineStatusMatches = true;
          }
        }
        matchesChips = (!typeFilterApplied || typeMatches) &&
            (!positionFilterApplied || positionMatches) &&
            (!connectionFilterApplied || connectionMatches) &&
            (!engineStatusFilterApplied || engineStatusMatches);
      }
      return matchesSearchQuery && matchesChips;
    }).toList();
    
    setState(() {
      _displayedVehicles = filteredList;
    });
  }

  VehicleTypeEnum? _getVehicleTypeEnumFromLabel(String label) {
    // Tu función helper (se mantiene como estaba)
    switch (label) {
      case 'Liviano': return VehicleTypeEnum.lightVehicle;
      case 'Tracto': return VehicleTypeEnum.tracto;
      case 'Rampla seca': return VehicleTypeEnum.ramplaSeca;
      case 'Camión 3/4': return VehicleTypeEnum.camion3_4;
      case 'Rampla fría': return VehicleTypeEnum.ramplaFria;
      case 'Cama baja': return VehicleTypeEnum.camaBaja;
      case 'Bus': return VehicleTypeEnum.bus;
      case 'Camión': return VehicleTypeEnum.truck;
      default: return null;
    }
  }

  Future<void> _refreshVehicles() async {
    _searchController.removeListener(_applyFilters);
    _currentFilters = {};
    _searchController.clear();
    await _loadVehiclesAndSetupFiltering();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      // 7. Envuelve el body en un Stack
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
          // 8. Muestra el overlay de carga dinámico
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
                        'Auditorías',
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
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  // Se extrajo el contenido del body para mayor claridad
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
    
    // Muestra "No hay resultados" solo si no está cargando y la lista está vacía.
    if (!_isLoading && _displayedVehicles.isEmpty) {
      return const Center(child: Text('No se encontraron resultados.'));
    }
    
    // Muestra la lista si no está cargando
    return _isLoading ? const SizedBox.shrink() : ListView.separated(
      itemCount: _displayedVehicles.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final vehicle = _displayedVehicles[index];
        return _buildVehicleTile(vehicle, context);
      },
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 80, endIndent: 20),
    );
  }

  // --- El resto de tus widgets de construcción no necesitan cambios ---
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar un móvil para auditar',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: GestureDetector(
            onTap: () async {
              final Set<String>? newFilters = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent, // Para que el borde redondeado del BottomSheet se vea
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
 //   String imageAssetPath = vehicleTypeEnum.imageAssetPath;

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
          vehicle.vehicleType.toVehicleTypeEnum().iconData, // ← Ahora devuelve IconData

          color: Colors.white,
       size: 20,
        )
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
            builder: (context) => AuditDetailsScreen(vehicle: vehicle),
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