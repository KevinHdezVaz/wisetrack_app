import 'package:flutter/material.dart';

// Importa todas las pantallas que vas a usar en las rutas
import 'package:wisetrack_app/ui/IntroPage/OnboardingWrapper.dart';
import 'package:wisetrack_app/ui/MenuPage/DashboardScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditoriaScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/BalanceScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/MobilesScreen.dart';
import 'package:wisetrack_app/ui/profile/SettingsScreen.dart';

void main() {
  runApp(const MyApp());
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

      // --- INICIO DE LA MODIFICACIÓN ---

      // La propiedad 'home' se reemplaza por 'initialRoute' y 'routes'.
      // home: const OnboardingWrapper(),

      // Define la primera ruta que se mostrará.
      // Si el usuario ya vio el Onboarding, podrías dirigirlo a '/dashboard'.
      // Por ahora, lo dejamos apuntando al Onboarding.
      initialRoute: '/',

      // Mapa de todas las rutas (pantallas) de la aplicación.
      routes: {
        // La ruta base '/' mostrará el OnboardingWrapper.
        '/': (context) => const OnboardingWrapper(),

        // Ruta para la pantalla principal del Dashboard.
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/dashboard2': (context) => const BalanceScreen(),

        '/auditoria': (context) => Auditoriascreen(),
        // Ruta para la pantalla de Móviles.
        '/mobiles': (context) => MobilesScreen(),

        // TODO: Añade aquí las rutas para el resto de tus pantallas a medida que las crees.
        // '/notifications': (context) => const NotificationsScreen(),
        // '/settings': (context) => const SettingsScreen(),
        // '/login': (context) => const LoginScreen(),
      },
      // --- FIN DE LA MODIFICACIÓN ---
    );
  }
}
