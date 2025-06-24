import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:wisetrack_app/data/models/alert/AlertModel.dart';
  import 'package:wisetrack_app/data/services/AlertService.dart'; // Importamos el nuevo servicio
import 'package:wisetrack_app/ui/MenuPage/notifications/NotificationDetailScreen.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';

 
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  // --- Estado de la UI y Datos ---
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _animationController;

  // Los filtros ahora se usarán para filtrar los datos reales
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Todas', 'Velocidad', 'Comandos', 'Posición', 'Arranque'];

  // Listas para almacenar las alertas obtenidas de la API
  List<Alertas> _allAlerts = [];
  List<Alertas> _todayAlerts = [];
  List<Alertas> _previouslyAlerts = [];


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _fetchAlerts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Llama al servicio para obtener las alertas y las procesa.
  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    _animationController.repeat();

    try {
      final alerts = await AlertService.getAlerts();
      if (mounted) {
        setState(() {
          _allAlerts = alerts;
          _applyFiltersAndGroup(); // Filtra y agrupa las alertas
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Error al cargar notificaciones.");
        print("Error en fetchAlerts: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  /// Filtra y agrupa las alertas en "Hoy" y "Anteriormente".
  void _applyFiltersAndGroup() {
    List<Alertas> filteredAlerts = List.from(_allAlerts);

    // Filtra por el chip seleccionado (excepto para "Todas")
    if (_selectedFilterIndex != 0) {
      final filter = _filters[_selectedFilterIndex].toLowerCase();
      filteredAlerts = _allAlerts.where((alert) {
        // Lógica de filtrado simple basada en el nombre de la alerta
        return alert.name.toLowerCase().contains(filter);
        
      }).toList();
    }
    
    // Separa en grupos de "Hoy" y "Anteriormente"
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<Alertas> todayList = [];
    List<Alertas> previouslyList = [];

    for (var alert in filteredAlerts) {
      if (alert.alertDate != null) {
        final alertDay = DateTime(alert.alertDate!.year, alert.alertDate!.month, alert.alertDate!.day);
        if (alertDay.isAtSameMomentAs(today)) {
          todayList.add(alert);
        } else {
          previouslyList.add(alert);
        }
      } else {
        previouslyList.add(alert); // Si no tiene fecha, va a "Anteriormente"
      }
    }

    setState(() {
      _todayAlerts = todayList;
      _previouslyAlerts = previouslyList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: const Text('Notificaciones', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: _isLoading ? const SizedBox.shrink() : _buildBodyContent(),
              ),
            ],
          ),
          if (_isLoading)
            Center(child: AnimatedTruckProgress(animation: _animationController)),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    if (_todayAlerts.isEmpty && _previouslyAlerts.isEmpty) {
      return const Center(child: Text('No hay notificaciones para mostrar.'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        if (_todayAlerts.isNotEmpty) ...[
          _buildSectionHeader('Hoy'),
          ..._todayAlerts.map((alert) => _buildNotificationTile(alert)).toList(),
        ],
        if (_previouslyAlerts.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('Anteriormente'),
          ..._previouslyAlerts.map((alert) => _buildNotificationTile(alert)).toList(),
        ],
        _buildFooter(),
      ],
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
                    _applyFiltersAndGroup(); // Vuelve a filtrar y agrupar con el nuevo filtro
                  });
                }
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: AppColors.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: _selectedFilterIndex == index ? AppColors.primary : Colors.black87),
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

  /// El ListTile ahora recibe un objeto 'Alert' y muestra sus datos.
  Widget _buildNotificationTile(Alertas alert) {
    bool isUnread = alert.status == 0; // Asumimos que status 0 = no leída

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: isUnread ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade200,
        child: Icon(
          _getIconForAlert(alert.name),
          color: AppColors.primary,
          size: 28,
        ),
      ),
      title: Row(
        children: [
          Text(alert.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          if (isUnread) ...[
            const SizedBox(width: 6),
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
          ],
          const Spacer(),
          Text(
            _formatAlertDate(alert.alertDate),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          'Móvil: ${alert.plate} - ${alert.driverName}',
          style: const TextStyle(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      isThreeLine: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationDetailScreen(alert: alert,)),
        );
      },
    );
  }

  /// Helper para devolver un ícono según el nombre de la alerta.
  IconData _getIconForAlert(String alertName) {
    String name = alertName.toLowerCase();
    if (name.contains('velocidad')) return Icons.speed;
    if (name.contains('combustible') || name.contains('arranque')) return Icons.local_gas_station;
    if (name.contains('destino') || name.contains('posición')) return Icons.location_on;
    if (name.contains('conduccion') || name.contains('descanso')) return Icons.time_to_leave;
    return Icons.notifications; // Ícono por defecto
  }

  /// Helper para formatear la fecha de la alerta.
  String _formatAlertDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final alertDay = DateTime(date.year, date.month, date.day);

    if (alertDay.isAtSameMomentAs(today)) {
      return DateFormat('HH:mm a').format(date); // '07:00 AM'
    } else if (alertDay.isAtSameMomentAs(yesterday)) {
      return 'Ayer';
    } else {
      return DateFormat('d MMM', 'es_ES').format(date); // '28 Abr'
    }
  }
  
 
  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
 

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
