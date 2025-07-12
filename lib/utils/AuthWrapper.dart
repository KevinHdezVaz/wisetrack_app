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
  Future<void> _checkSessionAndRedirect() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Pequeño delay

    final bool isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      bool hasSeenOnboarding = false;
      try {
        hasSeenOnboarding = await Preferences.hasSeenOnboarding();
      } catch (e) {
        print('Error checking onboarding status: $e');
        hasSeenOnboarding = false; 
      }

      if (!mounted) return;
      if (hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}