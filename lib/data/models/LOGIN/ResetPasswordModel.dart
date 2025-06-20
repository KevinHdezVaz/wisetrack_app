// Modelo para solicitud inicial
class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// Modelo para validación MFA
class MfaVerification {
  final String email;
  final String code;

  MfaVerification({required this.email, required this.code});

  Map<String, dynamic> toJson() => {'email': email, 'mfa': code};
}

// Modelo para cambio de contraseña
class NewPasswordData {
  final String email;
  final String newPass;
  final String newPassCheck;

  NewPasswordData({
    required this.email,
    required this.newPass,
    required this.newPassCheck,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'new_pass': newPass,
        'new_pass_check': newPassCheck,
      };
}

// Respuesta genérica
class PasswordResetResponse {
  final bool success;
  final String? message;

  PasswordResetResponse({required this.success, this.message});
}
