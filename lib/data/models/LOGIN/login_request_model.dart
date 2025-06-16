class LoginRequest {
  final String username;
  final String password;
  final String company;

  LoginRequest({
    required this.username,
    required this.password,
    required this.company,
  });

  // Convierte el objeto a JSON para enviarlo en la solicitud HTTP.
  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'company': company,
      };
}

class LoginResponse {
  final String token; // Ejemplo: Suponiendo que la API devuelve un token.
  final String? error; // Para manejar errores.

  LoginResponse({
    required this.token,
    this.error,
  });

  // Constructor desde JSON (respuesta de la API).
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '', // Ajusta según la estructura real.
      error: json['error'],
    );
  }
}
