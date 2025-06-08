import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/ui/login/ResetPasswordScreenUpdated.dart';

// Asumo que sigues usando tu archivo de colores.
// import 'path/to/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  bool _isNextButtonEnabled = false;
  bool _isResendButtonEnabled = false;

  late Timer _timer;
  int _countdown = 84; // 1 minuto y 24 segundos como en la imagen

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _isResendButtonEnabled = false;
      _countdown = 84;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _isResendButtonEnabled = true);
        _timer.cancel();
      }
    });
  }

  String get formattedTime {
    int minutes = _countdown ~/ 60;
    int seconds = _countdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
                  children: [
                    const SizedBox(height: 120),
                    _buildHeader(),
                    const SizedBox(height: 80),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Código de verificación',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                    ),
                    const SizedBox(height: 20),
                    _buildOtpInput(),
                    const SizedBox(height: 150),
                    _buildTimerDisplay(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
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
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Image.asset(
        'assets/images/backbtn.png',
        width: 50,
        height: 50,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Image.asset(
            'assets/images/rectangleForgot.png',
            width: MediaQuery.of(context).size.width * 0.7,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          bottom: 50,
          right: 0,
          child: Image.asset(
            'assets/images/rectangle2Forgot.png',
            width: MediaQuery.of(context).size.width * 0.8,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text('Recupera tu cuenta',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
        SizedBox(height: 16),
        Text(
            'Ingresa el código de verificación que enviamos a tu correo electrónico.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }

  Widget _buildOtpInput() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Pinput(
      length: 5,
      controller: _pinController,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
      ),
      onChanged: (value) {
        setState(() => _isNextButtonEnabled = value.length == 5);
      },
      onCompleted: (pin) {
        // Lógica para cuando el código se completa
        setState(() => _isNextButtonEnabled = true);
      },
    );
  }

  Widget _buildTimerDisplay() {
    return Text(
      formattedTime,
      style: TextStyle(
        fontSize: 16,
        color: _isResendButtonEnabled ? Colors.grey : AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isResendButtonEnabled ? () => startTimer() : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  vertical: 10), // Reducido de 16 a 10
              minimumSize: const Size(
                  0, 40), // Altura mínima de 40 (en lugar del default 48)
              side: BorderSide(
                  color: _isResendButtonEnabled
                      ? AppColors.primary
                      : AppColors.disabled,
                  width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              disabledForegroundColor: AppColors.disabled,
            ),
            child: Text(
              'Reenviar código',
              style: TextStyle(
                fontSize: 14, // Opcional: reducir tamaño de texto
                fontWeight: FontWeight.bold,
                color: _isResendButtonEnabled
                    ? AppColors.primary
                    : AppColors.disabled,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12), // Reducido el espacio entre botones
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isNextButtonEnabled
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordScreenUpdated(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.disabled,
              padding: const EdgeInsets.symmetric(
                  vertical: 10), // Reducido de 16 a 10
              minimumSize: const Size(0, 50), // Altura mínima de 40
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
            child: const Text(
              'Siguiente',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
