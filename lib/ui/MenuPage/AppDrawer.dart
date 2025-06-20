import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/services/auth_api_service.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart'; // Asegúrate de importar el widget

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Container(
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
                  iconColor: Colors.blueGrey,
                  onTap: () async {
                    setState(() => _isLoading = true);

                    // Ejecutar logout
                    try {
                      final response = await AuthService.logout();
                      print('Logout response: ${response.detail}');

                      // Redirigir a la pantalla de login
                      Navigator.of(context).pop(); // Cierra el Drawer
                      Navigator.of(context).pushReplacementNamed('/login');
                    } catch (e) {
                      print('Error durante logout: $e');

                      // Mostrar SnackBar con error (opcional)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar sesión: $e')),
                      );

                      // Redirigir a login incluso si hay error
                      Navigator.of(context).pop(); // Cierra el Drawer
                      Navigator.of(context).pushReplacementNamed('/login');
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildFooter(),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: AnimatedTruckProgress(
                progress: 1.0, // Progreso completo para simular carga
                duration: const Duration(milliseconds: 400),
              ),
            ), // Indicador de carga como overlay
        ],
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
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? routeName,
    Widget? trailing,
    Color iconColor = AppColors.primary,
    VoidCallback? onTap,
  }) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final bool isSelected = currentRoute == routeName;

    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      leading: Icon(icon,
          color: isSelected ? AppColors.primary : iconColor, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primary : Colors.black87,
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap ??
          () {
            Navigator.of(context).pop();
            if (routeName != null && !isSelected) {
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
          child: Text(
            count,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
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
