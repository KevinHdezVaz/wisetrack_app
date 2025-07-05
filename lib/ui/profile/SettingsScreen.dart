import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/models/User/UserDetail.dart';
import 'package:wisetrack_app/data/services/UserCacheService.dart';
 import 'package:wisetrack_app/data/services/UserService.dart';
import 'package:wisetrack_app/data/services/NotificationsService.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/ui/profile/EditProfileScreen.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  // State for user data
  UserData? _currentUser;
  
  // State for loading and animations
  bool _isLoading = true;
  late AnimationController _animationController;
  
  // State for notification settings
  bool _notificationsEnabled = false;
  bool _speedAlerts = false;
  bool _shortBreakAlerts = false;
  bool _noArrivalAlerts = false;
  bool _tenHoursDrivingAlerts = false;
  bool _continuousDrivingAlerts = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadInitialData(); // Load all initial data
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Loads all necessary data for the screen in parallel.
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Run the loading of notification settings and user data in parallel
      await Future.wait([
        _loadNotificationSettings(),
        _loadUserData(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.stop();
        });
      }
    }
  }

  /// Fetches user data, trying cache first, then network.
  Future<void> _loadUserData() async {
    final cachedUser = await UserCacheService.getCachedUserData();
    if (cachedUser != null) {
      if (mounted) {
        setState(() => _currentUser = cachedUser);
      }
      return; // Found in cache, no need to call network
    }

    // If not in cache, fetch from network
    try {
      final userDetailResponse = await UserService.getUserDetail();
      if (mounted) {
        setState(() => _currentUser = userDetailResponse.data);
        // Save to cache for next time
        await UserCacheService.saveUserData(userDetailResponse.data);
      }
    } catch (e) {
      print('Failed to load user data from network: $e');
    }
  }

  /// Fetches notification settings from the service.
  Future<void> _loadNotificationSettings() async {
    final permissions = await NotificationService.getNotificationPermissions();
    if (mounted) {
      setState(() {
        _notificationsEnabled = permissions.allowNotification;
        _speedAlerts = permissions.alertPermissions.maxSpeed;
        _shortBreakAlerts = permissions.alertPermissions.shortBreak;
        _noArrivalAlerts = permissions.alertPermissions.noArrivalAtDestination;
        _tenHoursDrivingAlerts = permissions.alertPermissions.tenHoursDriving;
        _continuousDrivingAlerts = permissions.alertPermissions.continuousDriving;
      });
    }
  }

  /// Saves all current settings to the backend.
  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
      _animationController.repeat();
    });
    try {
      // This could also be parallelized with Future.wait if the API supports it
      await NotificationService.updateSingleNotificationPermission(name: 'allow_notification', value: _notificationsEnabled);
      await NotificationService.updateSingleNotificationPermission(name: 'Velocidad Maxima', value: _speedAlerts);
      await NotificationService.updateSingleNotificationPermission(name: 'descanso corto', value: _shortBreakAlerts);
      await NotificationService.updateSingleNotificationPermission(name: 'No presentación en destino', value: _noArrivalAlerts);
      await NotificationService.updateSingleNotificationPermission(name: 'conduccion 10 Horas', value: _tenHoursDrivingAlerts);
      await NotificationService.updateSingleNotificationPermission(name: 'conduccion continua', value: _continuousDrivingAlerts);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuraciones guardadas con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.stop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Configuraciones',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(
              child: AnimatedTruckProgress(animation: _animationController),
            )
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  children: [
                    // --- DYNAMIC USER PROFILE TILE ---
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: _currentUser?.userImage != null && _currentUser!.userImage.isNotEmpty
                            ? NetworkImage(_currentUser!.userImage)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider, // Fallback to a local asset
                        onBackgroundImageError: (exception, stackTrace) {
                           // Handle image load error if needed
                        },
                      ),
                      title: Text(
                        _currentUser?.fullName ?? 'Cargando...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Editar perfil'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfileScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // --- NOTIFICATION SETTINGS ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Las notificaciones push aparecerán en la pantalla de bloqueo de tu teléfono, incluso cuando no estés usando la app.',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          value: _notificationsEnabled,
                          onChanged: (bool value) => setState(() => _notificationsEnabled = value),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // --- ALERT TYPES ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tipos de alertas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildSwitchTile('Velocidad Maxima', _speedAlerts, (val) => setState(() => _speedAlerts = val)),
                        _buildSwitchTile('Descanso corto', _shortBreakAlerts, (val) => setState(() => _shortBreakAlerts = val)),
                        _buildSwitchTile('No presentación en destino', _noArrivalAlerts, (val) => setState(() => _noArrivalAlerts = val)),
                        _buildSwitchTile('Conducción 10 horas', _tenHoursDrivingAlerts, (val) => setState(() => _tenHoursDrivingAlerts = val)),
                        _buildSwitchTile('Conducción continua', _continuousDrivingAlerts, (val) => setState(() => _continuousDrivingAlerts = val)),
                      ],
                    ),
                    const SizedBox(height: 80), // Space for the floating button
                  ],
                ),
                // --- SAVE BUTTON ---
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      child: const Text(
                        'Guardar cambios',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Helper widget to build a consistent switch tile.
  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}