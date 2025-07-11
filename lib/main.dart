import 'dart:io'; // Para HttpOverrides

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase Core
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wisetrack_app/data/services/notification_service.dart';
import 'package:wisetrack_app/firebase_options.dart';
import 'package:wisetrack_app/ui/IntroPage/OnboardingWrapper.dart';
import 'package:wisetrack_app/ui/MenuPage/DashboardScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditoriaScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/CombinedDashboardScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/MobilesScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/notifications/NotificationsScreen.dart';
import 'package:wisetrack_app/ui/SplashScreen.dart';
import 'package:wisetrack_app/ui/login/LoginScreen.dart';
import 'package:wisetrack_app/ui/profile/SettingsScreen.dart';
import 'package:wisetrack_app/utils/AuthWrapper.dart';

// Configuración para ignorar errores de certificado HTTPS (solo para desarrollo)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
   WidgetsFlutterBinding.ensureInitialized(); // Necesario para Firebase

// --- 3. CARGA EL ARCHIVO .ENV ---
  await dotenv.load(fileName: ".env");
  print('✅ Archivo de entorno .env cargado.');

  try {
    // --- 4. INICIALIZA FIREBASE USANDO LAS OPCIONES ---
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente para la plataforma actual.');
  } catch (e, stack) {
    print('❌ Error crítico inicializando Firebase: $e');
    print('Stack trace: $stack');
  }
 
   
  
   HttpOverrides.global = MyHttpOverrides();  
  initializeDateFormatting('es_ES', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiseTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.blue.withOpacity(0.3),
          selectionHandleColor: Colors.blue,
          cursorColor: Colors.blue,
        ),
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
        '/auditoria': (context) => AuditoriaScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}