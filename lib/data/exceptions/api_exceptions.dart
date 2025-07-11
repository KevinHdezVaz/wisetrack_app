// lib/core/exceptions/api_exceptions.dart

/// Clase base para todas las excepciones de la API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Representa un error de 'Recurso no encontrado' (Error 404).
class NotFoundException extends ApiException {
  NotFoundException({String message = "Recurso no encontrado."}) 
    : super(message: message, statusCode: 404);
}

/// Representa un error de 'No autorizado' (Error 401).
/// Usualmente porque el token es inválido o las credenciales son incorrectas.
class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = "Credenciales incorrectas o inválidas."}) 
    : super(message: message, statusCode: 401);
}

/// Representa un error genérico del servidor (Errores 5xx).
class ServerException extends ApiException {
  ServerException({String message = "Error inesperado en el servidor."}) 
    : super(message: message, statusCode: 500);
}

/// Representa un error de conexión (no se pudo comunicar con el servidor).
class ConnectionException extends ApiException {
  ConnectionException({String message = "Error de conexión. Revisa tu internet."}) 
    : super(message: message);
}