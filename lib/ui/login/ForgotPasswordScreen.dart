import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/services/auth_api_service.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/ui/login/VerificationCodeScreen.dart';
// Asegúrate que la ruta a VerificationCodeScreen sea correcta. Lo he cambiado a OtpVerificationScreen según tu código.
 import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart'; // Asegúrate que este es el AnimatedWidget que creamos antes

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin { // El TickerProvider ya estaba, ¡perfecto!
  final _emailController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Duración de un ciclo de animación
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // --- LÓGICA REFACTORIZADA ---
  // He movido la lógica a su propio método para mayor claridad
  Future<void> _requestReset() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese un correo válido')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    // Inicia la animación en bucle para mostrar la carga
    _animationController.repeat();

    try {
      final response = await AuthService.requestPasswordReset(email);

      // Cuando la respuesta llega, completa la animación actual
      await _animationController.forward(from: _animationController.value);
      _animationController.stop();

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Código enviado con éxito')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            // El nombre de tu pantalla es OtpVerificationScreen en tu código original
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Error al enviar el código')),
        );
      }
    } catch (e) {
      if (mounted) {
        _animationController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 120),
                    _buildHeader(),
                    const SizedBox(height: 120),
                    _buildForm(),
                    const SizedBox(height: 200),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            left: 16.0,
            child: _buildBackButton(context),
          ),
          // --- AQUÍ SE MUESTRA EL OVERLAY DE CARGA ---
          if (_isLoading)
            Center(
              child: AnimatedTruckProgress(
                // Pasamos el controlador completo, no solo el valor
                animation: _animationController,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        } catch (e) {
          print('Error al navegar: $e');
        }
      },
      child: Image.asset(
        'assets/images/backbtn.png', // Asegúrate que esta imagen existe
        width: 50,
        height: 50,
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    // Tu fondo personalizado
    return Stack(
      children: [
        Positioned(
            top: 0,
            right: -100, // Ajustado para que se parezca más a los ejemplos anteriores
            child: Image.asset('assets/images/rectangle1.png', // Asegúrate que esta imagen existe
                width: MediaQuery.of(context).size.width * 0.5)),
        Positioned(
            bottom: 0,
            left: -40, // Ajustado para que se parezca más a los ejemplos anteriores
            child: Image.asset('assets/images/rectangle2.png', // Asegúrate que esta imagen existe
                width: MediaQuery.of(context).size.width * 0.6)),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          'Recupera tu cuenta',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
        SizedBox(height: 16),
        Text(
          'Ingresa tu correo electrónico para recibir el código de restablecimiento', // Texto ligeramente modificado para mayor claridad
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Correo electrónico',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'tucorreo@ejemplo.com',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Llamamos al nuevo método refactorizado
        onPressed: (_isButtonEnabled && !_isLoading) ? _requestReset : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isButtonEnabled && !_isLoading
              ? AppColors.primary
              : AppColors.disabled,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 0,
        ),
        child: const Text(
          'Siguiente',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}