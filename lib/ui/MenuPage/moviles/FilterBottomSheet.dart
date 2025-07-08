import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/models/vehicles/Vehicle.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  // Recibe los filtros iniciales para poder precargarlos
  final Set<String> initialFilters;

  const FilterBottomSheet({Key? key, required this.initialFilters})
      : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Filtros seleccionados por el usuario
  late Set<String> _selectedFilters;

  // --- INICIO: Estado para manejar la carga de datos ---
  bool _isLoading = true;
  String? _errorMessage;
  List<VehicleType> _vehicleTypes = [];
  // --- FIN: Estado para manejar la carga de datos ---

  @override
  void initState() {
    super.initState();
    _selectedFilters = Set.from(widget.initialFilters);
    // Llama al método para obtener los datos cuando el widget se inicializa
    _fetchVehicleTypes();
  }

  /// Obtiene los tipos de vehículo desde el servicio y actualiza el estado.
  Future<void> _fetchVehicleTypes() async {
    try {
      final types = await VehicleService.getVehicleTypes();
      if (mounted) {
        setState(() {
          _vehicleTypes = types;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al cargar tipos de vehículo.";
          _isLoading = false;
        });
      }
    }
  }

  void _handleSelection(String label) {
    setState(() {
      if (_selectedFilters.contains(label)) {
        _selectedFilters.remove(label);
      } else {
        _selectedFilters.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtros',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // --- INICIO: Construcción dinámica de la sección de filtros ---
              _buildVehicleTypeSection(),
              // --- FIN: Construcción dinámica ---
              _buildFilterSection('Posición', ['Válida', 'Inválida']),
              _buildFilterSection('Conexión', ['Online', 'Offline']),
              _buildFilterSection('Estado de motor', ['Encendido', 'Apagado']),
              _buildFilterSection(
                  'Filtro 1', ['Opción A', 'Opción B', 'Opción C', 'Opción D']),
              _buildFilterSection(
                  'Filtro 2', ['Opción E', 'Opción F', 'Opción G']),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, <String>{}),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                    ),
                    child: const Text('Borrar filtros',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 14.0)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selectedFilters),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                    ),
                    child: Text(
                        _selectedFilters.isEmpty
                            ? 'Ver resultados'
                            : 'Ver ${_selectedFilters.length} resultado(s)',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14.0)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget que decide si mostrar un indicador de carga, un error o la lista de filtros.
  Widget _buildVehicleTypeSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
    }

    if (_errorMessage != null) {
      return Center(
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    // Si todo va bien, crea la lista de nombres a partir de los datos obtenidos.
    final typeNames = _vehicleTypes.map((type) => type.name).toList();

    return _buildFilterSection('Tipo de vehículo', typeNames);
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
          const SizedBox(height: 6.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children:
                options.map((option) => _buildFilterChip(option)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilters.contains(label);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87, fontSize: 13.0),
      ),
      selected: isSelected,
      onSelected: (bool selected) => _handleSelection(label),
      backgroundColor: Colors.grey.shade200,
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    );
  }
}
