import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  
import 'package:wisetrack_app/data/models/alert/AlertModel.dart';
  import 'package:wisetrack_app/data/services/AlertService.dart';  
import 'package:wisetrack_app/ui/MenuPage/notifications/NotificationDetailScreen.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';
import 'package:wisetrack_app/utils/ReadStatusManager.dart';

 
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _animationController;

  int _selectedFilterIndex = 0;
  List<String> _filters = ['Todas']; 

  List<AlertType> _alertTypes = []; // Lista de tipos de alerta del servicio


  List<Alertas> _allAlerts = [];
  List<Alertas> _todayAlerts = [];
  List<Alertas> _previouslyAlerts = [];
  Set<String> _readAlertIds = {};

   final Map<String, List<String>> _alertCategories = {
    'Velocidad': ['Velocidad Maxima'],
    'Conducción': [
      'Alerta conduccion 10 Horas',
      'Alerta conduccion continua',
      'Alerta descanso corto'
    ],
    'Destino': ['No presentación en destino'],
    'Otros': [] 
  };



  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _fetchInitialData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleNotificationTap(Alertas alert) {
    final alertId = ReadStatusManager.getUniqueId(alert.plate, alert.alertDate);
    
     if (!_readAlertIds.contains(alertId)) {
      setState(() {
        _readAlertIds.add(alertId);
      });
      ReadStatusManager.markAlertAsRead(alertId);
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationDetailScreen(alert: alert)),
    );
  }

void _generateFiltersFromAlerts(List<Alertas> alerts) {
  // Primero obtenemos todos los tipos de alerta únicos que existen realmente
  final availableTypes = alerts
      .map((alert) => alert.alertType.name) // Usamos el nombre del tipo, no de la alerta
      .toSet() // Eliminamos duplicados
      .toList();

  setState(() {
    _filters = ['Todas', ...availableTypes];
  });
}

void _applyFiltersAndGroup() {
  List<Alertas> filteredAlerts = _allAlerts;

  if (_selectedFilterIndex != 0) {
    final selectedType = _filters[_selectedFilterIndex];
    filteredAlerts = _allAlerts.where((alert) {
      // Comparamos con el nombre del tipo de alerta, no con el nombre de la alerta
      return alert.alertType.name == selectedType;
    }).toList();
  }
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  _todayAlerts = filteredAlerts.where((alert) {
    if (alert.alertDate == null) return false;
    final alertDay = DateTime(alert.alertDate!.year, alert.alertDate!.month, alert.alertDate!.day);
    return alertDay.isAtSameMomentAs(today);
  }).toList();

  _previouslyAlerts = filteredAlerts.where((alert) {
    if (alert.alertDate == null) return true;
    final alertDay = DateTime(alert.alertDate!.year, alert.alertDate!.month, alert.alertDate!.day);
    return !alertDay.isAtSameMomentAs(today);
  }).toList();

  setState(() {});
}



  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    _animationController.repeat();

    try {
      final results = await Future.wait([
        AlertService.getAlerts(),
        AlertService.getAlertTypes(), // Obtenemos los tipos de alerta
        ReadStatusManager.getReadAlertIds(),
      ]);
      
      final alerts = results[0] as List<Alertas>;
      final alertTypes = results[1] as List<AlertType>;
      final readIds = results[2] as Set<String>;

      if (mounted) {
        setState(() {
          _allAlerts = alerts;
          _alertTypes = alertTypes;
          _readAlertIds = readIds;
          
          // Generar filtros dinámicamente
          _generateFiltersFromAlerts(alerts);
          _applyFiltersAndGroup();
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
                    _applyFiltersAndGroup();  
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
   Widget _buildNotificationTile(Alertas alert) {
    final alertId = ReadStatusManager.getUniqueId(alert.plate, alert.alertDate);
    final bool isUnread = !_readAlertIds.contains(alertId);

    // Buscamos el tipo de alerta correspondiente para obtener más datos si es necesario
    final alertType = _alertTypes.firstWhere(
      (type) => type.name == alert.name,
      orElse: () => AlertType(id: 0, name: alert.name),
    );

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: isUnread ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade200,
        child: Icon(_getIconForAlert(alertType.name), color: AppColors.primary, size: 28),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              alertType.name, // Usamos el nombre del tipo de alerta
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 6),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
          ],
          const SizedBox(width: 8),
          Text(_formatAlertDate(alert.alertDate), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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
      onTap: () => _handleNotificationTap(alert), 
    );
  }


   IconData _getIconForAlert(String alertName) {
    String name = alertName.toLowerCase();
    if (name.contains('velocidad')) return Icons.speed;
    if (name.contains('conduccion') || name.contains('horas') || name.contains('continua')) return Icons.time_to_leave;
    if (name.contains('descanso')) return Icons.hotel;
    if (name.contains('destino')) return Icons.location_on;
    return Icons.notifications; // Ícono por defecto
  }

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
