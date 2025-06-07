import 'package:flutter/material.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
// Asegúrate de que las rutas a tus archivos personalizados sean correctas
import 'custom_dialogs.dart';

class SecurityActionsScreen extends StatelessWidget {
  const SecurityActionsScreen({Key? key}) : super(key: key);

  /// Simula una llamada a un servidor para realizar una acción.
  ///
  /// En una aplicación real, aquí harías una petición HTTP.
  /// Devolverá 'true' para simular un éxito y 'false' para un error.
  Future<bool> _simulateApiCall() async {
    // Muestra un indicador de carga mientras se realiza la operación (opcional pero recomendado)
    // Por ejemplo:
    // showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()));

    // Esperamos 2 segundos para simular la demora de la red.
    await Future.delayed(const Duration(seconds: 2));

    // Simula un resultado aleatorio: 70% de éxito, 30% de error.
    // En tu app, aquí verificarías la respuesta real del servidor.
    // Por ejemplo: if (response.statusCode == 200) return true;
    return (DateTime.now().second % 10) < 7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: const Text(
          'Acciones de seguridad',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          _buildSectionTitle('Combustible'),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.local_gas_station_outlined,
            label: 'Corte de combustible',
            onTap: () {
              // --- Flujo de Diálogos para "Corte de combustible" ---
              // 1. Muestra el diálogo de PRECAUCIÓN
              showWarningDialog(
                context,
                title: 'Cortar combustible',
                subtitle: 'Esta acción es crítica. ¿Estás seguro de continuar?',
                // 2. Lógica que se ejecuta si el usuario presiona "Continuar"
                onConfirm: () async {
                  bool success =
                      await _simulateApiCall(); // Llama a la API simulada

                  // 3. Muestra ÉXITO o ERROR según el resultado
                  if (success) {
                    showSuccessDialog(context,
                        title: 'Corte realizado',
                        subtitle: 'El combustible ha sido cortado con éxito.');
                  } else {
                    showErrorDialog(context);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.power_settings_new_outlined,
            label: 'Activar combustible',
            onTap: () {
              showWarningDialog(
                context,
                title: 'Activar combustible',
                subtitle: '¿Estás seguro de que deseas realizar esta acción?',
                onConfirm: () async {
                  bool success = await _simulateApiCall();
                  if (success) {
                    showSuccessDialog(context,
                        title: 'Combustible activado',
                        subtitle: 'La acción se ha realizado con éxito.');
                  } else {
                    showErrorDialog(context);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.password,
            label: 'Código de corte',
            onTap: () {
              // TODO: Lógica para la pantalla o modal de "Código de corte"
            },
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('Chapa randómica'),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.lock_open_outlined,
            label: 'Destrabar chapa randómica',
            onTap: () {
              // TODO: Lógica para destrabar chapa
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.lock_outline,
            label: 'Trabar chapa randómica',
            onTap: () {
              // TODO: Lógica para trabar chapa
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.password,
            label: 'Código de chapa randómica',
            onTap: () {
              // TODO: Lógica para el código de chapa
            },
          ),
        ],
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
