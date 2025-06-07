import 'package:flutter/material.dart';
// Asegúrate de que esta importación sea correcta para tu proyecto
import 'package:wisetrack_app/ui/color/app_colors.dart';

class ResetPasswordScreenUpdated extends StatefulWidget {
  const ResetPasswordScreenUpdated({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenUpdatedState createState() =>
      _ResetPasswordScreenUpdatedState();
}

enum PasswordStrength { none, weak, acceptable, secure }

class _ResetPasswordScreenUpdatedState
    extends State<ResetPasswordScreenUpdated> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _hasMinLength = true;
  bool _hasMixedCase = true;
  bool _hasNumber = true;
  bool _hasSpecialChar = true;
  bool _passwordsMatch = false;

  bool _userHasTyped = false;

  PasswordStrength _strength = PasswordStrength.none;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validatePassword);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    int strengthScore = 0;

    if (password.isNotEmpty && !_userHasTyped) {
      _userHasTyped = true;
    }

    setState(() {
      if (!_userHasTyped) {
        _hasMinLength = true;
        _hasMixedCase = true;
        _hasNumber = true;
        _hasSpecialChar = true;
        _strength = PasswordStrength.none;
        _passwordsMatch = password.isEmpty && confirmPassword.isEmpty;
        return;
      }

      _hasMinLength = password.length >= 8;
      if (_hasMinLength) strengthScore++;

      _hasMixedCase = password.contains(RegExp(r'[a-z]')) &&
          password.contains(RegExp(r'[A-Z]'));
      if (_hasMixedCase) strengthScore++;

      _hasNumber = password.contains(RegExp(r'[0-9]'));
      if (_hasNumber) strengthScore++;

      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      if (_hasSpecialChar) strengthScore++;

      _passwordsMatch = password.isNotEmpty && password == confirmPassword;

      if (strengthScore == 0 && password.isEmpty) {
        _strength = PasswordStrength.none;
        _userHasTyped = false;
      } else if (strengthScore <= 1) {
        _strength = PasswordStrength.weak;
      } else if (strengthScore <= 3) {
        _strength = PasswordStrength.acceptable;
      } else {
        _strength = PasswordStrength.secure;
      }
    });
  }

  bool get _isButtonEnabled {
    return _userHasTyped &&
        _hasMinLength &&
        _hasMixedCase &&
        _hasNumber &&
        _hasSpecialChar &&
        _passwordsMatch;
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildValidationChecks(),
                  const SizedBox(height: 24),
                  _buildForm(),
                  const SizedBox(height: 16),
                  _buildStrengthIndicator(),
                  const SizedBox(height: 40),
                  _buildContinueButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Positioned(
            // ← Botón después, encima de todo
            top: 40.0,
            left: 16.0,
            child: _buildBackButton(context),
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
            // Opcional: navegar a una ruta específica si no hay stack
            Navigator.pushReplacementNamed(context, '/login');
          }
        } catch (e) {
          print('Error al navegar: $e');
        }
      },
      child: Image.asset(
        'assets/images/backbtn.png',
        width: 50,
        height: 50,
      ),
    );
  }

  // --- INICIO DE LA MODIFICACIÓN ---
  Widget _buildStrengthIndicator() {
    if (_strength == PasswordStrength.none) return const SizedBox.shrink();

    String imagePath;
    String text;
    Color textColor;

    switch (_strength) {
      case PasswordStrength.weak:
        imagePath = 'assets/images/password_debil.png';
        text = 'Contraseña débil';
        textColor = Colors.red;
        break;
      case PasswordStrength.acceptable:
        imagePath = 'assets/images/password_aceptable.png';
        text = 'Contraseña aceptable';
        textColor = Colors.orange;
        break;
      case PasswordStrength.secure:
        imagePath = 'assets/images/password_segura.png';
        text = 'Contraseña segura';
        textColor = Color(0xFF0EC59B);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // La imagen que ya tenías
        Image.asset(imagePath),
        const SizedBox(height: 8),
        // El texto descriptivo que faltaba
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
  // --- FIN DE LA MODIFICACIÓN ---

  Widget _buildBackground(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: 0,
            right: -100,
            child: Image.asset('assets/images/rectangle1.png',
                width: MediaQuery.of(context).size.width * 0.5)),
        Positioned(
            bottom: 0,
            left: -40,
            child: Image.asset('assets/images/rectangle2.png',
                width: MediaQuery.of(context).size.width * 0.6)),
      ],
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ingresa tu',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.0, // Elimina espacio adicional
            ),
          ),
          Text(
            'nueva contraseña',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationChecks() {
    return Column(
      children: [
        _buildRequirementRow('Al menos 8 caracteres', _hasMinLength),
        _buildRequirementRow('Mayúsculas y minúsculas', _hasMixedCase),
        _buildRequirementRow('Un número', _hasNumber),
        _buildRequirementRow('Un símbolo especial', _hasSpecialChar),
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(isMet ? Icons.check_circle : Icons.cancel,
              color: isMet ? Colors.green : Colors.red, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 15, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildPasswordField(
          label: 'Contraseña',
          controller: _passwordController,
          isVisible: _isPasswordVisible,
          onToggleVisibility: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        const SizedBox(height: 20),
        _buildPasswordField(
          label: 'Repite la contraseña',
          controller: _confirmPasswordController,
          isVisible: _isConfirmPasswordVisible,
          onToggleVisibility: () => setState(
              () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          style: TextStyle(
            // Estilo para aumentar el tamaño de los asteriscos
            fontSize: 16, // Tamaño aumentado (valor original suele ser 16)
            letterSpacing:
                1.5, // Espaciado entre caracteres para mejor legibilidad
          ),
          decoration: InputDecoration(
            hintText: 'Ingresa tu clave de acceso',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.border)),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.black, // Color negro para el icono
                size: 24, // Tamaño opcionalmente aumentado
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(
                // Ajuste de padding interno
                vertical: 16,
                horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isButtonEnabled
            ? () {/* TODO: Lógica para cambiar contraseña */}
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.disabled,
          padding:
              const EdgeInsets.symmetric(vertical: 10), // Reducido de 16 a 10
          minimumSize:
              const Size(0, 42), // Altura mínima reducida (default es 48)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Text(
          'Continuar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
