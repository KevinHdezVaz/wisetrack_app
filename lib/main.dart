import 'dart:io'; // --> 1. IMPORTA LA LIBRERÍA 'io'

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wisetrack_app/ui/IntroPage/OnboardingWrapper.dart';
import 'package:wisetrack_app/ui/MenuPage/DashboardScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditoriaScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/CombinedDashboardScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/MobilesScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/notifications/NotificationsScreen.dart';
import 'package:wisetrack_app/ui/SplashScreen.dart';
import 'package:wisetrack_app/ui/login/LoginScreen.dart';
import 'package:wisetrack_app/ui/profile/SettingsScreen.dart';
import 'package:wisetrack_app/utils/AuthWrapper.DART';

// --> 2. AÑADE ESTA CLASE PARA IGNORAR LOS ERRORES DE CERTIFICADO
//     Esta clase anula el comportamiento por defecto de las llamadas HTTP.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // --> 3. APLICA LA ANULACIÓN ANTES DE CORRER LA APP
  //     Esto le dice a toda tu aplicación que use las reglas definidas en MyHttpOverrides.
  HttpOverrides.global = MyHttpOverrides();

  // Se inicializa la localización para español.
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
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const SplashScreen(),
      routes: {
        '/auth_wrapper': (context) => const AuthWrapper(),

        '/onboarding': (context) => const OnboardingWrapper(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/dashboard_combined': (context) => const CombinedDashboardScreen(),
        '/mobiles': (context) => MobilesScreen(),
        '/auditoria': (context) =>
            Auditoriascreen(), // Asegúrate que el nombre de la clase sea correcto
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
