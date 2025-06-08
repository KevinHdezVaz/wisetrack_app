import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- Importaciones de tus pantallas ---
// Es una buena práctica tener un archivo "barril" para exportar todas las pantallas
// pero por ahora las importamos una por una.
import 'package:wisetrack_app/ui/IntroPage/OnboardingWrapper.dart';
import 'package:wisetrack_app/ui/MenuPage/DashboardScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditoriaScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/CombinedDashboardScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/MobilesScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/notifications/NotificationsScreen.dart';
import 'package:wisetrack_app/ui/SplashScreen.dart';
import 'package:wisetrack_app/ui/login/LoginScreen.dart';
import 'package:wisetrack_app/ui/profile/SettingsScreen.dart';

// --- Importa la pantalla que maneja la lógica del Splash Screen ---

void main() {
  // Se inicializa la localización para español ANTES de correr la app.
  // Esto soluciona los errores de formato de fecha en toda la aplicación.
  initializeDateFormatting('es_ES', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiseTrack App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Define un color de fondo base para los Scaffolds si quieres
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      // --- ESTRUCTURA DE NAVEGACIÓN CORREGIDA ---

      // Usamos 'home' para establecer el punto de entrada de la app.
      // LandingScreen se encargará de mostrar el splash y luego navegar a la ruta '/onboarding'.
      home: const SplashScreen(),

      // 'routes' define todas las pantallas a las que se puede navegar por nombre.
      routes: {
        // Pantallas del flujo inicial
        '/onboarding': (context) => const OnboardingWrapper(),
        '/login': (context) => const LoginScreen(), // Podrías añadirla aquí

        // Pantallas principales después del login/onboarding
        '/dashboard': (context) => const DashboardScreen(),
        '/dashboard_combined': (context) => const CombinedDashboardScreen(),
        '/mobiles': (context) => MobilesScreen(),
        '/auditoria': (context) =>
            Auditoriascreen(), // Asegúrate que el nombre de la clase sea correcto
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),

        // Puedes añadir rutas a pantallas de detalle aquí también
        // '/vehicle_detail': (context) => const VehicleDetailScreen(),
        // '/notification_detail': (context) => const NotificationDetailScreen(),
      },
    );
  }
}
