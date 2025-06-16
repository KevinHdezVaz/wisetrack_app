// archivo: app_drawer.dart
import 'package:flutter/material.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
// import 'path/to/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // --- INICIO DE LA MODIFICACIÓN ---
                  // Pasamos el contexto y la ruta a la que queremos navegar
                  _buildDrawerItem(
                      context: context,
                      icon: Icons.home_filled,
                      title: 'Inicio',
                      routeName:
                          '/dashboard' // Puedes usar la misma ruta del dashboard o crear una nueva
                      ),
                  _buildDrawerItem(
                      context: context,
                      icon: Icons.directions_bus,
                      title: 'Móviles',
                      routeName:
                          '/mobiles' // La nueva ruta para la pantalla de Móviles
                      ),
                  _buildDrawerItem(
                      context: context,
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      routeName: '/dashboard_combined'),

                  // ... resto de los items ...
                  _buildDrawerItem(
                      context: context,
                      icon: Icons.insights,
                      title: 'Auditorías',
                      routeName:
                          '/auditoria' // Descomentar cuando tengas la pantalla
                      ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.notifications,
                    title: 'Notificaciones',
                    routeName:
                        '/notifications', // Descomentar cuando tengas la pantalla
                    trailing: _buildNotificationBadge('3'),
                  ),
                  _buildDrawerItem(
                      context: context,
                      icon: Icons.settings,
                      title: 'Configuraciones',
                      routeName:
                          '/settings' // Descomentar cuando tengas la pantalla
                      ),
                  // --- FIN DE LA MODIFICACIÓN ---
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            _buildDrawerItem(
              context: context,
              icon: Icons.exit_to_app,
              title: 'Cerrar sesión',
              iconColor: Colors.blueGrey,
              // onTap: () { /* Lógica especial para cerrar sesión */ }
            ),
            const Divider(height: 1, color: Colors.black12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Hola Francisca!',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context, // Necesario para la navegación
    required IconData icon,
    required String title,
    String? routeName, // La ruta a la que se va a navegar
    Widget? trailing,
    Color iconColor = AppColors.primary,
    VoidCallback?
        onTap, // Mantenemos onTap para acciones especiales como logout
  }) {
    // Obtenemos la ruta actual para saber si el ítem está seleccionado
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final bool isSelected = currentRoute == routeName;

    return ListTile(
      selected: isSelected, // Marca el ítem como seleccionado
      selectedTileColor: AppColors.primary
          .withOpacity(0.1), // Color de fondo cuando está seleccionado
      leading: Icon(icon,
          color: isSelected ? AppColors.primary : iconColor, size: 28),
      title: Text(title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : Colors.black87,
          )),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap ??
          () {
            // Cerramos el drawer primero
            Navigator.of(context).pop();

            if (routeName != null && !isSelected) {
              // Usamos pushNamed para navegar a la ruta definida.
              // Usamos pushReplacementNamed si no queremos que el usuario pueda volver atrás.
              Navigator.of(context).pushNamed(routeName);
            }
          },
    );
  }

  Widget _buildNotificationBadge(String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(count,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
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
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
