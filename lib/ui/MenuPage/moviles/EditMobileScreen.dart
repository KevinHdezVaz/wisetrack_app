import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/SuccessDialog.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
// Asegúrate de que la ruta a tus colores sea la correcta
// import 'app_colors.dart';

class EditMobileScreen extends StatefulWidget {
  const EditMobileScreen({Key? key}) : super(key: key);

  @override
  _EditMobileScreenState createState() => _EditMobileScreenState();
}

class _EditMobileScreenState extends State<EditMobileScreen> {
  final List<String> vehicleTypes = [
    'Tracto',
    'Camión 3/4',
    'Rampla Seca',
    'Liviano Fría',
    'Liviano',
    'Cama baja',
  ];

  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: const Text(
          'Editar móvil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de móvil:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                _buildCustomDropdown(),
              ],
            ),
          ),
          _buildSaveChangesButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/backbtn.png', // Reutilizando el botón de regreso
        width: 40,
        height: 40,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildCustomDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: _buildDropdownItem(
            null, 'Selecciona un tipo'), // Placeholder inicial
        items: vehicleTypes
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: _buildDropdownItem(Icons.image_outlined, item),
                ))
            .toList(),
        value: selectedValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          selectedMenuItemBuilder: (context, child) {
            return Container(
              color: AppColors.primary.withOpacity(0.1),
              child: child,
            );
          },
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(IconData? icon, String text) {
    return Row(
      children: [
        Icon(icon ?? Icons.image_outlined, size: 22, color: Colors.grey),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSaveChangesButton() {
    final bool isEnabled = selectedValue != null;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: ElevatedButton(
          // --- INICIO DE LA MODIFICACIÓN ---
          onPressed: isEnabled
              ? () {
                  // Muestra el diálogo de éxito
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const SuccessDialog();
                    },
                  );
                }
              : null,
          // --- FIN DE LA MODIFICACIÓN ---
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.disabled,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
          ),
          child: const Text(
            'Guardar cambios',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
