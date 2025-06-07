// archivo: filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final Set<String> _selectedFilters = {
    'Camión 3/4',
    'Online',
    'Encendido',
    'Opción F'
  };

  // Método para manejar la selección de un chip
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
    // Solución al error de Overflow: Envolvemos la columna en un SingleChildScrollView
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado del modal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filtros',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // Secciones de filtros
            _buildFilterSection('Tipo de vehículo', [
              'Tracto',
              'Rampla seca',
              'Camión 3/4',
              'Liviano',
              'Rampla fría',
              'Cama baja'
            ]),
            _buildFilterSection('Posición', ['Válida', 'Inválida']),
            _buildFilterSection('Conexión', ['Online', 'Offline']),
            _buildFilterSection('Estado de motor', ['Encendido', 'Apagado']),
            _buildFilterSection(
                'Filtro 1', ['Opción A', 'Opción B', 'Opción C', 'Opción D']),
            _buildFilterSection(
                'Filtro 2', ['Opción E', 'Opción F', 'Opción G']),

            const SizedBox(height: 30.0),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _selectedFilters.clear()),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text('Borrar filtros',
                      style: TextStyle(color: AppColors.primary)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  // El texto del botón ahora es dinámico
                  child: Text(
                      _selectedFilters.isEmpty
                          ? 'Ver resultados'
                          : 'Ver ${_selectedFilters.length} resultados',
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para cada sección de filtros
  Widget _buildFilterSection(String title, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                options.map((option) => _buildFilterChip(option)).toList(),
          ),
        ],
      ),
    );
  }

  // Widget para construir cada chip de filtro
  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilters.contains(label);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      ),
      selected: isSelected,
      onSelected: (bool selected) => _handleSelection(label),
      backgroundColor: Colors.grey.shade200,
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      showCheckmark: false, // Opcional: para quitar el checkmark por defecto
    );
  }
}
