import 'package:flutter/material.dart';
// --- INICIO DE LA CORRECCIÓN ---
// Se cambió 'date_symbol_data_file.dart' por 'date_symbol_data_local.dart'
import 'package:intl/date_symbol_data_local.dart';
// --- FIN DE LA CORRECCIÓN ---

// Importa todas las pantallas que vas a usar en las rutas
import 'package:wisetrack_app/ui/IntroPage/OnboardingWrapper.dart';
import 'package:wisetrack_app/ui/MenuPage/DashboardScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditoriaScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/BalanceScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/CombinedDashboardScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/DataVisualizationScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/MobilesScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/notifications/NotificationsScreen.dart';
import 'package:wisetrack_app/ui/profile/SettingsScreen.dart';

void main() {
  // Se inicializa la localización para español antes de correr la app.
  initializeDateFormatting('es_ES', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // La ruta inicial que se muestra al arrancar.
      initialRoute: '/',

      // Mapa de todas las rutas (pantallas) de la aplicación.
      routes: {
        // La ruta base '/' mostrará el OnboardingWrapper.
        '/': (context) => const OnboardingWrapper(),

        // Ruta para la pantalla principal del Dashboard.
        '/dashboard': (context) => const DashboardScreen(),

        '/notifications': (context) => const NotificationsScreen(),
        // Ruta para la pantalla de Configuraciones.
        '/settings': (context) => const SettingsScreen(),

        // Ruta para la pantalla de Balance (Dashboard 2).
        '/dashboard2': (context) => const CombinedDashboardScreen(),

        // Ruta para la pantalla de Auditorías.
        '/auditoria': (context) =>
            Auditoriascreen(), // Asegúrate que el nombre de la clase es correcto

        // Ruta para la pantalla de Móviles.
        '/mobiles': (context) => MobilesScreen(),

        // TODO: Añade aquí las rutas para el resto de tus pantallas.
        // '/notifications': (context) => const NotificationsScreen(),
        // '/login': (context) => const LoginScreen(),
      },
    );
  }
}
