import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/models/NotificationItem.dart';
import 'package:wisetrack_app/ui/MenuPage/notifications/NotificationDetailScreen.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
// Asegúrate de importar tu modelo y tus colores
// import 'notification_model.dart';
// import 'app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'Excesos de velocidad',
    'Comandos',
    'Posición',
    'Arranque'
  ];

  // Datos de ejemplo
  final List<NotificationItem> _todayNotifications = const [
    NotificationItem(
      title: 'Exceso de velocidad',
      description:
          'El vehículo AAAA - 12 superó el límite de velocidad permitido en Autopista Sur.',
      time: '07:00 AM',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      isUnread: true,
    ),
  ];

  final List<NotificationItem> _previouslyNotifications = const [
    NotificationItem(
      title: 'Arranque de motor',
      description:
          'El vehículo FLWO - 34 fue encendido a las 03:17 a.m. fuera del horario autorizado.',
      time: '03:17 AM',
      date: 'Ayer',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
      isUnread: true,
    ),
    NotificationItem(
      title: 'Corte de combustible',
      description:
          'Se ejecutó el corte de combustible del vehículo VXN - 90 tras una alerta de uso no permitido en zona de riesgo.',
      time: '16:00 PM',
      date: 'Ayer',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      isUnread: true,
    ),
    NotificationItem(
      title: 'Exceso de velocidad',
      description:
          'El vehículo YTR - 56 reanudó el flujo de combustible luego de validación exitosa del operador autorizado.',
      time: '17:00 PM',
      date: '28 Abril',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
    ),
    NotificationItem(
      title: 'Exceso de velocidad',
      description:
          'El vehículo RTBA - 15 superó el límite de velocidad permitido en Autopista Sur.',
      time: '09:00 AM',
      date: '5 Abril',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: const Text('Notificaciones',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                _buildSectionHeader('Hoy'),
                ..._todayNotifications
                    .map((notification) => _buildNotificationTile(notification))
                    .toList(),
                const SizedBox(height: 16),
                _buildSectionHeader('Anteriormente'),
                ..._previouslyNotifications
                    .map((notification) => _buildNotificationTile(notification))
                    .toList(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: _selectedFilterIndex == index,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedFilterIndex = index;
                    // TODO: Lógica para filtrar notificaciones
                  });
                }
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: AppColors.primary.withOpacity(0.1),
              labelStyle: TextStyle(
                  color: _selectedFilterIndex == index
                      ? AppColors.primary
                      : Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNotificationTile(NotificationItem notification) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(notification.avatarUrl),
      ),
      title: Row(
        children: [
          Text(notification.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          if (notification.isUnread) ...[
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
            ),
          ],
          const Spacer(),
          Text(
            notification.date != null
                ? '${notification.date} ${notification.time}'
                : notification.time,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(notification.description,
            style: const TextStyle(fontSize: 14)),
      ),
      isThreeLine: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          Text('¿No encuentras más notificaciones?',
              style: TextStyle(color: Colors.grey.shade700)),
          TextButton(
            onPressed: () {
              // TODO: Navegar a la pantalla de historial
            },
            child: const Text('Ir al historial',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
