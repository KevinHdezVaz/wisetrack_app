import 'package:flutter/material.dart';
import 'package:wisetrack_app/utils/Preferences.dart'; // 1. Importa tus preferencias
import 'package:wisetrack_app/data/services/auth_api_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {

  @override
  void initState() {
    super.initState();
    _checkSessionAndRedirect();
  }
 

  // MODIFICADO: Este método ahora tiene toda la lógica de decisión
  Future<void> _checkSessionAndRedirect() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Pequeño delay

    final bool isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // 1. Si el usuario TIENE sesión, va directo al dashboard.
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // 2. Si NO tiene sesión, entonces revisamos si ya vio el onboarding.
      bool hasSeenOnboarding = false;
      try {
        hasSeenOnboarding = await Preferences.hasSeenOnboarding();
      } catch (e) {
        print('Error checking onboarding status: $e');
        // Por seguridad, si hay un error lo mandamos al onboarding
        hasSeenOnboarding = false; 
      }

      if (!mounted) return;

      // 3. Decidimos entre login y onboarding.
      if (hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // La pantalla de carga se mantiene igual.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}