import 'package:flutter/material.dart';

// No necesitamos importar las otras pantallas aquí
// import 'package:wisetrack_app/ui/IntroPage/OnboardingWrapper.dart';
// import 'package:wisetrack_app/ui/login/LoginScreen.dart';
// import 'package:wisetrack_app/utils/Preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Las animaciones se quedan exactamente igual
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // MODIFICADO: Simplificamos la lógica de navegación
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Mantenemos el delay inicial para que la animación se vea
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Ya no revisamos el estado de onboarding aquí.

      // Iniciamos la animación de salida y LUEGO navegamos.
      _controller.forward().then((_) {
        // Navegamos SIEMPRE a la misma ruta: nuestro widget decisor.
        Navigator.pushReplacementNamed(context, '/auth_wrapper');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // El widget build se queda exactamente igual.
    return Scaffold(
      backgroundColor: const Color(0xFF008C95),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Image.asset(
                  'assets/images/logoApp.png',
                  width: 300,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/rectangleSplash.png',
                fit: BoxFit.cover,
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.0),
                child: Text(
                  'Powered by Wisetrack',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
