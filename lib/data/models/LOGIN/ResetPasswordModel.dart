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
  final String newPassword;
  final String confirmation;

  NewPasswordData({
    required this.email,
    required this.newPassword,
    required this.confirmation,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'new_pass': newPassword,
        'new_pass_check': confirmation,
      };
}

// Respuesta genérica
class PasswordResetResponse {
  final bool success;
  final String? message;

  PasswordResetResponse({required this.success, this.message});
}
