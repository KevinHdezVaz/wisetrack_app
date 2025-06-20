import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/FilterBottomSheet.dart'; // Asegúrate de que esta importación sea correcta
import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditDetailsScreen.dart'; // Tu pantalla de detalles de auditoría
import 'package:wisetrack_app/ui/color/app_colors.dart';

import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart'; // Importa tus modelos de Vehicle

class Auditoriascreen extends StatefulWidget {
  const Auditoriascreen({Key? key}) : super(key: key);

  @override
  _AuditoriascreenState createState() => _AuditoriascreenState();
}

class _AuditoriascreenState extends State<Auditoriascreen> {
  // Ahora guardamos la lista completa de vehículos y la lista que se muestra (filtrada)
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _displayedVehicles = []; // La lista que se mostrará en la UI
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController =
      TextEditingController(); // Controlador para la barra de búsqueda
  Set<String> _currentFilters =
      {}; // Filtros actualmente aplicados desde el BottomSheet

  @override
  void initState() {
    super.initState();
    _loadVehiclesAndSetupFiltering(); // Llama a una nueva función para cargar y configurar
  }

  // Carga los vehículos de la API y configura el listener de filtrado
  Future<void> _loadVehiclesAndSetupFiltering() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final vehicles = await VehicleService.getAllVehicles();
      if (mounted) {
        setState(() {
          _allVehicles = vehicles;
          _displayedVehicles =
              vehicles; // Inicialmente, mostramos todos los vehículos
          _isLoading = false;
        });
        // Configura el listener después de cargar los datos
        _searchController.addListener(_applyFilters);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          debugPrint('Error al cargar vehículos para auditoría: $e');
        });
      }
    }
  }

  // <--- LÓGICA DE FILTRADO COMBINADA (búsqueda por texto + filtros de chip) ---
  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<Vehicle> filteredList = _allVehicles.where((vehicle) {
      // 1. Filtrado por texto de búsqueda (plate)
      final matchesSearchQuery = vehicle.plate.toLowerCase().contains(query);

      // 2. Filtrado por chips seleccionados
      bool matchesChips =
          true; // Por defecto, si no hay chips seleccionados, coincide

      if (_currentFilters.isNotEmpty) {
        // Necesitas mapear los labels de los filtros a las propiedades del objeto Vehicle
        // Estos mappings son cruciales y deben coincidir con los labels en FilterBottomSheet

        bool typeFilterApplied = false;
        bool typeMatches = false;
        bool positionFilterApplied = false;
        bool positionMatches = false;
        bool connectionFilterApplied = false;
        bool connectionMatches = false;
        bool engineStatusFilterApplied = false;
        bool engineStatusMatches = false;

        for (final filterLabel in _currentFilters) {
          // Filtro por 'Tipo de vehículo'
          final vehicleTypeEnumFromFilter =
              _getVehicleTypeEnumFromLabel(filterLabel);
          if (vehicleTypeEnumFromFilter != null) {
            typeFilterApplied = true;
            if (vehicle.vehicleType.toVehicleTypeEnum() ==
                vehicleTypeEnumFromFilter) {
              typeMatches =
                  true; // Si al menos un tipo de vehículo seleccionado coincide
            }
          }

          // Filtro por 'Posición'
          if (filterLabel == 'Válida') {
            positionFilterApplied = true;
            if (vehicle.statusVehicle == 1) positionMatches = true;
          } else if (filterLabel == 'Inválida') {
            positionFilterApplied = true;
            if (vehicle.statusVehicle == 0) positionMatches = true;
          }

          // Filtro por 'Conexión'
          if (filterLabel == 'Online') {
            connectionFilterApplied = true;
            if (vehicle.statusDevice == 1) connectionMatches = true;
          } else if (filterLabel == 'Offline') {
            connectionFilterApplied = true;
            if (vehicle.statusDevice == 0) connectionMatches = true;
          }

          // Filtro por 'Estado de motor' (asumo que status_vehicle = 1 es Encendido y 0 es Apagado para motor)
          if (filterLabel == 'Encendido') {
            engineStatusFilterApplied = true;
            if (vehicle.statusVehicle == 1) engineStatusMatches = true;
          } else if (filterLabel == 'Apagado') {
            engineStatusFilterApplied = true;
            if (vehicle.statusVehicle == 0) engineStatusMatches = true;
          }

          // Puedes añadir lógica para 'Filtro 1', 'Filtro 2', etc., aquí si los datos están en 'Vehicle'
        }

        // Combina todas las condiciones de los chips
        // Un vehículo debe coincidir si:
        // - No hay filtros de ese tipo O al menos un filtro de ese tipo coincide
        matchesChips = (!typeFilterApplied || typeMatches) &&
            (!positionFilterApplied || positionMatches) &&
            (!connectionFilterApplied || connectionMatches) &&
            (!engineStatusFilterApplied || engineStatusMatches);

        // Y añadir lógica para Filtro 1 y Filtro 2 si son relevantes a las propiedades del vehículo
      }

      return matchesSearchQuery && matchesChips;
    }).toList();
    setState(() {
      // <--- Mover setState aquí para reconstruir después de filtrar
      _displayedVehicles = filteredList;
    });
  }

  // Helper para mapear labels de filtro a VehicleTypeEnum (inverso a imageAssetPath)
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
      // Añade más mapeos si tienes otros tipos en tu FilterBottomSheet
      case 'Bus':
        return VehicleTypeEnum.bus;
      case 'Camión':
        return VehicleTypeEnum.truck; // Asegúrate de que este mapeo es correcto
      default:
        return null;
    }
  }

  // Refresca la lista de vehículos (vuelve a cargar de la API)
  Future<void> _refreshVehicles() async {
    _searchController
        .removeListener(_applyFilters); // Quita el listener antes de recargar
    _currentFilters = {}; // Borra los filtros al refrescar completamente
    _searchController.clear(); // Limpia la barra de búsqueda
    await _loadVehiclesAndSetupFiltering(); // Vuelve a cargar y configura el listener
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters); // Limpia el listener
    _searchController.dispose(); // Libera el controlador
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
                          'Auditorias',
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
      body: Column(
        children: [
          _buildSearchBar(context), // La barra de búsqueda con el controlador
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 40),
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage ??
                                  'Error al cargar los móviles para auditoría',
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
                              height: 1,
                              indent: 80,
                              endIndent: 20,
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController, // Asigna el controlador
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
              // Hacemos la función asíncrona
              final Set<String>? newFilters = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return FilterBottomSheet(
                      initialFilters:
                          _currentFilters); // Pasa los filtros actuales
                },
              );

              // Si se devolvieron filtros (no fue null)
              if (newFilters != null && mounted) {
                setState(() {
                  _currentFilters = newFilters;
                  _applyFilters(); // Re-aplica los filtros con los nuevos seleccionados
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
    bool isKeyActive =
        false; // Asumiendo no hay datos directos de llave en tu JSON
    bool isShieldActive =
        false; // Asumiendo no hay datos directos de escudo en tu JSON

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
        /*
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuditDetailsScreen(vehicle: vehicle),
          ),
        );*/
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
