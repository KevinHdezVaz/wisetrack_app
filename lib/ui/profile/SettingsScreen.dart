import 'package:flutter/material.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/ui/profile/EditProfileScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- Estados para cada interruptor (Switch) ---
  bool _notificationsEnabled = true;
  bool _speedAlerts = true;
  bool _geofenceAlerts = true;
  bool _commandAlerts = true;
  bool _engineStartAlerts = true;
  bool _extraAlert1 = true;
  bool _extraAlert2 = false; // Ejemplo de uno desactivado
  bool _extraAlert3 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: const Text(
          'Configuraciones',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Usamos un ListView para que el contenido sea desplazable
          ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildNotificationsSection(),
              const SizedBox(height: 24),
              _buildAlertTypesSection(),
              const SizedBox(
                  height:
                      80), // Espacio para que el botón no tape el último item
            ],
          ),
          // Botón fijo en la parte inferior
          _buildSaveChangesButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    // Reutilizando el botón de regreso de pantallas anteriores
    return IconButton(
      icon: Image.asset(
        'assets/images/backbtn.png', // Asegúrate de tener esta imagen
        width: 40,
        height: 40,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildProfileSection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        radius: 30,
        backgroundImage:
            NetworkImage('https://i.pravatar.cc/150?img=1'), // Placeholder
      ),
      title: const Text(
        'Francisca Sepúlveda',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('Editar perfil'),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notificaciones',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Las notificaciones push aparecerán en la pantalla de bloqueo de tu teléfono, incluso cuando no estés usando la app.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          value: _notificationsEnabled,
          onChanged: (bool value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildAlertTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipos de alertas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSwitchTile('Excesos de velocidad', _speedAlerts,
            (val) => setState(() => _speedAlerts = val)),
        _buildSwitchTile('Posición en geocerca peligrosa', _geofenceAlerts,
            (val) => setState(() => _geofenceAlerts = val)),
        _buildSwitchTile('Comandos', _commandAlerts,
            (val) => setState(() => _commandAlerts = val)),
        _buildSwitchTile('Arranque de motor', _engineStartAlerts,
            (val) => setState(() => _engineStartAlerts = val)),
        _buildSwitchTile('Alerta extra 1', _extraAlert1,
            (val) => setState(() => _extraAlert1 = val)),
        _buildSwitchTile('Alerta extra 2', _extraAlert2,
            (val) => setState(() => _extraAlert2 = val)),
        _buildSwitchTile('Alerta extra 3', _extraAlert3,
            (val) => setState(() => _extraAlert3 = val)),
      ],
    );
  }

  // Widget reutilizable para cada fila con un interruptor
  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildSaveChangesButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // TODO: Lógica para guardar los cambios
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
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
