import 'package:flutter/material.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/EditMobileScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/SecurityActionsScreen.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/ui/login/VerificationCodeScreen.dart';

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  // Back button (alineado a la izquierda)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      'assets/images/backbtn.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  // Espacio flexible que empuja el título al centro
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'AAAA - 12',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Image.asset(
                              'assets/images/icons_editar.png',
                              width: 25,
                              height: 25,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditMobileScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Espacio invisible para balancear el botón de retroceso
                  const SizedBox(
                      width: 40), // Mismo ancho que el botón de retroceso
                ],
              ),
            ),
            // Body content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildTopStatusCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Reportabilidad'),
                  _buildDataRow('Último reporte', '2024-10-21  11:31:46'),
                  const SizedBox(height: 12),
                  _buildDataRow('Ubicación', 'Zona descarga - Aeropuerto Scl.'),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Seguridad'),
                  _buildDataRow('Alimentación', '12.74 V'),
                  const SizedBox(height: 12),
                  _buildDataRow('Corte de combustible', 'Sin datos'),
                  const SizedBox(height: 40),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/backbtn.png',
        width: 40,
        height: 40,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildTopStatusCard() {
    return Card(
      color: Colors.white, // Fondo blanco
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          color: Colors.grey, // Borde gris claro
          width: 1.0, // Grosor del borde
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem(Icons.location_on, 'Posición', 'Válida'),
            const SizedBox(height: 40, child: VerticalDivider()),
            _buildStatusItem(Icons.gps_fixed, 'Conexión', 'Online'),
            const SizedBox(height: 40, child: VerticalDivider()),
            _buildStatusItem(Icons.vpn_key, 'Estado', 'Encendido'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String title, String status) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryIconos, size: 28),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, color: Colors.grey, size: 14),
          ],
        ),
        const SizedBox(height: 4),
        Text(status),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.primaryIconos, // Cyan line color
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.primaryIconos, // Cyan line color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(
            value,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Lógica para ir a Auditoría
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
            child: const Text('Auditoría',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecurityActionsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.shield_outlined, color: Colors.white),
            label: const Text('Acciones de Seguridad',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
          ),
        ),
      ],
    );
  }
}
