import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wisetrack_app/data/models/LOGIN/ResetPasswordModel.dart';
import 'package:wisetrack_app/data/models/LOGIN/login_request_model.dart';
import 'package:wisetrack_app/data/models/LOGIN/logout_response.dart';
import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

class AuthService {
  // Método para iniciar sesión (con guardado automático del token)
  static Future<LoginResponse> login({
    required String username,
    required String password,
    required String company,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/user-login');
    final body = LoginRequest(
      username: username,
      password: password,
      company: company,
    ).toJson();

    print('Intentando login - URL: $url');
    print('Cuerpo de la solicitud: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Respuesta recibida - Status Code: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        print('Login exitoso - Token: ${loginResponse.token}');

        // Guarda el token automáticamente al hacer login exitoso
        if (loginResponse.token.isNotEmpty) {
          await TokenStorage.saveToken(loginResponse.token);
          print('Token guardado exitosamente en TokenStorage');
        }

        return loginResponse;
      } else {
        final errorMsg = 'Error: ${response.statusCode} - ${response.body}';
        print('Error en login: $errorMsg');
        return LoginResponse(
          token: '',
          error: errorMsg,
        );
      }
    } catch (e) {
      print('Excepción en login: $e');
      return LoginResponse(
        token: '',
        error: 'Exception: $e',
      );
    }
  }

  // Método para cerrar sesión (con eliminación automática del token)
  static Future<LogoutResponse> logout() async {
    final token = await TokenStorage.getToken();
    print('Intentando logout - Token obtenido: $token');

    if (token == null) {
      print('Error: No hay token almacenado');
      return LogoutResponse(
        success: false,
        message: 'No hay token almacenado',
      );
    }

    final url = Uri.parse('${Constants.baseUrl}/user-logout');
    print('URL de logout: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      print('Respuesta recibida - Status Code: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      // Elimina el token independientemente de la respuesta del servidor
      await TokenStorage.deleteToken();
      print('Token eliminado de TokenStorage');

      if (response.statusCode == 200) {
        return LogoutResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorMsg = 'Error: ${response.statusCode}';
        print('Error en logout: $errorMsg');
        return LogoutResponse(
          success: false,
          message: errorMsg,
        );
      }
    } catch (e) {
      await TokenStorage.deleteToken();
      print('Excepción en logout: $e');
      return LogoutResponse(
        success: false,
        message: 'Exception: $e',
      );
    }
  }

  // Método auxiliar para obtener el token almacenado
  static Future<String?> getStoredToken() async {
    final token = await TokenStorage.getToken();
    print('Obteniendo token almacenado: $token');
    return token;
  }

  // Método para verificar si hay un token activo
  static Future<bool> isLoggedIn() async {
    final hasToken = await TokenStorage.hasToken();
    print('Verificando si está logueado: $hasToken');
    return hasToken;
  }

  // Paso 1: Solicitar reset (GET)
  static Future<PasswordResetResponse> requestPasswordReset(
      String email) async {
    final url = Uri.parse('${Constants.baseUrl}/user/reset-password/$email');
    print('Solicitando reset de contraseña - URL: $url');

    try {
      final response = await http.get(url);
      print('Respuesta recibida - Status Code: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        print('Solicitud de reset exitosa');
        return PasswordResetResponse(success: true);
      } else {
        final errorMsg =
            jsonDecode(response.body)['error'] ?? 'Error desconocido';
        print('Error en reset: $errorMsg');
        return PasswordResetResponse(
          success: false,
          message: errorMsg,
        );
      }
    } catch (e) {
      print('Excepción en requestPasswordReset: $e');
      return PasswordResetResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Paso 2: Validar MFA (POST)
  static Future<PasswordResetResponse> verifyMfaCode({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/user/reset-password/$email');
    final body = MfaVerification(email: email, code: code).toJson();
    print('Validando MFA - URL: $url');
    print('Cuerpo de la solicitud: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Respuesta recibida - Status Code: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        print('Validación MFA exitosa');
        return PasswordResetResponse(success: true);
      } else {
        final errorMsg =
            jsonDecode(response.body)['error'] ?? 'Código inválido';
        print('Error en MFA: $errorMsg');
        return PasswordResetResponse(
          success: false,
          message: errorMsg,
        );
      }
    } catch (e) {
      print('Excepción en verifyMfaCode: $e');
      return PasswordResetResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Paso 3: Cambiar contraseña (POST)
  static Future<PasswordResetResponse> setNewPassword({
    required String email,
    required String newPassword,
    required String confirmation,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/user/reset-password/$email');
    final body = NewPasswordData(
      email: email,
      newPassword: newPassword,
      confirmation: confirmation,
    ).toJson();
    print('Cambiando contraseña - URL: $url');
    print('Cuerpo de la solicitud: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Respuesta recibida - Status Code: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        print('Cambio de contraseña exitoso');
        return PasswordResetResponse(success: true);
      } else {
        final errorMsg =
            jsonDecode(response.body)['error'] ?? 'Error al cambiar contraseña';
        print('Error en setNewPassword: $errorMsg');
        return PasswordResetResponse(
          success: false,
          message: errorMsg,
        );
      }
    } catch (e) {
      print('Excepción en setNewPassword: $e');
      return PasswordResetResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }
}
