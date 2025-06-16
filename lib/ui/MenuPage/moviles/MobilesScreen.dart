import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/models/VehicleType.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/FilterBottomSheet.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/VehicleDetailScreen.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class MobilesScreen extends StatelessWidget {
  MobilesScreen({Key? key}) : super(key: key);

  // Solución: Se quitó 'const' de la declaración de la lista.
  final List<Vehicle> mockVehicles = [
    Vehicle(
        name: 'ABBA - 12',
        type: VehicleType.bus,
        isLocationActive: true,
        isGpsActive: true,
        isKeyActive: true),
    Vehicle(
        name: 'BCCB - 10',
        type: VehicleType.bus,
        isLocationActive: true,
        isGpsActive: true,
        isKeyActive: true),
    Vehicle(name: 'CDDC - 15', type: VehicleType.truck),
    Vehicle(
        name: 'EFFE - 13',
        type: VehicleType.bus,
        isLocationActive: true,
        isGpsActive: true,
        isKeyActive: true),
    Vehicle(
        name: 'BCCB - 14',
        type: VehicleType.bus,
        isLocationActive: true,
        isGpsActive: true,
        isKeyActive: true),
    // ...y así con el resto de tus vehículos
  ];

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
                // Back button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image.asset(
                    'assets/images/backbtn.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                // Título centrado con icono
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
                            fontSize: 18, // Ajustado para coincidir con el otro
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
                // Espacio para balancear
                const SizedBox(
                    width: 40), // Igual que el ancho del botón de retroceso
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: ListView.separated(
              itemCount: mockVehicles.length,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (context, index) {
                return _buildVehicleTile(mockVehicles[index], context);
              },
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 80, // Indentación para que no empiece desde el borde
                endIndent: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/backbtn.png', // Usando la misma imagen de antes
        width: 40,
        height: 40,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
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
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return const FilterBottomSheet();
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Transform.scale(
                scale: 0.7, // Escala el ícono al 70% de su tamaño original
                child: ImageIcon(
                  const AssetImage('assets/images/icon_filter.png'),
                  color: AppColors.primary,
                  size: 10, // Usa el tamaño original
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTile(Vehicle vehicle, BuildContext context) {
    Color iconBgColor = vehicle.type == VehicleType.bus
        ? AppColors.primary.withOpacity(0.8)
        : Colors.red.shade400;
    IconData vehicleIcon = vehicle.type == VehicleType.bus
        ? Icons.directions_bus
        : Icons.local_shipping;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconBgColor,
        child: Icon(vehicleIcon, color: Colors.white, size: 20),
      ),
      title: Text(
        vehicle.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _statusIcon(Icons.location_on, vehicle.isLocationActive),
          _statusIcon(Icons.gps_fixed, vehicle.isGpsActive),
          _statusIcon(Icons.vpn_key, vehicle.isKeyActive),
          _statusIcon(Icons.shield, vehicle.isShieldActive),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailScreen(),
          ),
        );
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
