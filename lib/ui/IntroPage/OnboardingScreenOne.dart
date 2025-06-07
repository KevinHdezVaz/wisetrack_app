import 'package:flutter/material.dart';
import 'package:wisetrack_app/ui/IntroPage/OnboardingScreenTwo.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class OnboardingScreenOne extends StatelessWidget {
  final PageController pageController;

  const OnboardingScreenOne({Key? key, required this.pageController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. WIDGET PARA LA IMAGEN DE FONDO
          // Coloca la imagen en la parte superior de la pantalla.
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              // Asegúrate de que esta ruta sea correcta
              'assets/images/rectangle1.png',
              width: MediaQuery.of(context).size.width * 0.5,
              fit: BoxFit.contain,
            ),
          ),

          // Contenido principal de la pantalla
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Imagen principal de la ilustración
                  Image.asset(
                    'assets/images/introPage1.png', // Reemplaza con tu ilustración principal
                    height: 400,
                  ),
                  const SizedBox(height: 50),

                  // Título principal
                  const Text(
                    'Seguimiento en línea',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Subtítulo
                  const Text(
                    'Monitoreo de tu flota en tiempo real.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),

                  // Fila para el indicador de página y el botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Indicador de página
                      Row(
                        children: [
                          // Primer punto (largo)
                          Container(
                            width: 80.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Segundo punto (ahora largo)
                          Container(
                            width:
                                8.0, // Puedes ajustar este valor para cambiar el largo
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(
                                  4.0), // Esquinas redondeadas
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Tercer punto (círculo pequeño)
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      // Botón de continuar
                      ElevatedButton(
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
