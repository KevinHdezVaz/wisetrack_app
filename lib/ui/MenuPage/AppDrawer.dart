import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/services/UserCacheService.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

import '../../data/models/User/UserDetail.dart';

// Ya no necesita ser StatefulWidget
class AppDrawer extends StatelessWidget {
  // 1. Acepta la función de callback en el constructor
  final VoidCallback onLogout;


  final VoidCallback? onNavigate;

  const AppDrawer({
    Key? key,
    required this.onLogout,
    this.onNavigate, // <-- Añade esto
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      // Ya no necesita un Stack aquí
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home_filled,
                    title: 'Inicio',
                    routeName: '/dashboard',
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.directions_bus,
                    title: 'Móviles',
                    routeName: '/mobiles',
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    routeName: '/dashboard_combined',
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.insights,
                    title: 'Auditorías',
                    routeName: '/auditoria',
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.notifications,
                    title: 'Notificaciones',
                    routeName: '/notifications',
                    trailing: _buildNotificationBadge('3'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings,
                    title: 'Configuraciones',
                    routeName: '/settings',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            _buildDrawerItem(
              context: context,
              icon: Icons.exit_to_app,
              title: 'Cerrar sesión',
              iconColor: AppColors.ColorFooter,
              // 2. El onTap ahora simplemente llama al callback
              onTap: () {
                // Primero cierra el drawer para que se vea la animación en la pantalla completa
                Navigator.of(context).pop(); 
                // Luego llama a la función de logout que vive en DashboardScreen
                onLogout();
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
 
// --- Reemplaza tu método con este ---
Widget _buildDrawerHeader() {
  // FutureBuilder se encarga de esperar el resultado de getCachedUserData()
  return FutureBuilder<UserData?>(
    future: UserCacheService.getCachedUserData(), // 1. El Future que debe esperar
    builder: (context, snapshot) { // 2. La función que construye la UI

      String userName = 'Invitado'; // Valor por defecto

      // 3. Verificamos el estado del Future
      if (snapshot.connectionState == ConnectionState.done) {
        // Si el future terminó...
        if (snapshot.hasData && snapshot.data != null) {
          // ...y tenemos datos, usamos el nombre real.
          userName = snapshot.data!.fullName; // Usamos el getter que ya tenías
        } else if (snapshot.hasError) {
          // ...y hubo un error, podríamos mostrar un mensaje.
          userName = 'Error';
          print('Error al cargar datos del usuario desde caché: ${snapshot.error}');
        }
      }
      // Mientras el future está cargando (connectionState == waiting), se mostrará 'Invitado'.
      // Podrías poner "Cargando..." si prefieres.

      // 4. Construimos el widget final con el nombre obtenido
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Hola $userName!', // Usamos la variable con el nombre dinámico
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? routeName,
    Widget? trailing,
    Color iconColor = AppColors.ColorFooter,
    VoidCallback? onTap,
  }) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final bool isSelected = currentRoute == routeName;

    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColors.ColorFooter.withOpacity(0.1),
      leading: Icon(icon, color: isSelected ? AppColors.ColorFooter : iconColor, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.ColorFooter : Colors.black87,
        ),
      ),
      trailing: trailing,
      // --- PASO 2: Llama a onNavigate antes de navegar ---
      onTap: onTap ??
          () {
            // Llama a la función que nos pasaron para pausar el timer
            onNavigate?.call(); 
            
            // Luego, ejecuta la navegación normal
            Navigator.of(context).pop();
            if (routeName != null && !isSelected) {
              Navigator.of(context).pushNamed(routeName);
            }
          },
    );
  }

  Widget _buildNotificationBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _footerLink('Términos y Condiciones'),
          const SizedBox(height: 12),
          _footerLink('Preguntas frecuentes'),
          const SizedBox(height: 12),
          _footerLink('Soporte'),
          const SizedBox(height: 12),
          _footerLink('Acerca de Wisetrack Protect'),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.ColorFooter,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}