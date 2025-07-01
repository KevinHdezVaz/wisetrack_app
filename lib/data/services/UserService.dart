import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

class UserService {
  static Future<UserDetail> getUserDetail() async {
    // 1. Obtener token con manejo de errores
    final token = await _getTokenWithValidation();
    print('✅ Token obtenido para user/detail');

    // 2. Configurar request
    final url = Uri.parse('${Constants.baseUrl}/user/detail');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    print('🌐 Configurando solicitud a: ${url.toString()}');

    try {
      // 3. Hacer la petición con timeout
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('🔄 Respuesta recibida - Status: ${response.statusCode}');
      debugPrint('📄 Body: ${response.body}');

      // 4. Procesar respuesta
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('❌ Error de conexión: ${e.message}');
      throw _handleNetworkError(e);
    } on TimeoutException {
      print('⏰ Timeout excedido (15 segundos)');
      throw Exception('El servidor no respondió a tiempo');
    } catch (e) {
      print('‼️ Error inesperado: $e');
      throw Exception('Error desconocido: $e');
    }
  }

  // --- Métodos auxiliares ---
  
  static Future<String> _getTokenWithValidation() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        print('🔐 Error: Token nulo o vacío');
        throw Exception('Authentication required: Invalid token');
      }
      return token;
    } catch (e) {
      print('⚠️ Error al obtener token: $e');
      rethrow;
    }
  }

  static UserDetail _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['data'] == null) {
            throw FormatException('El campo "data" no existe en la respuesta');
          }
          return UserDetail.fromJson(jsonResponse);
        } on FormatException catch (e) {
          print('📊 Error de formato JSON: $e');
          throw Exception('Datos de usuario corruptos: $e');
        }
      case 401:
        print('🔒 Error 401: Token inválido/expirado');
        throw Exception('Tu sesión ha expirado. Por favor inicia sesión nuevamente');
      case 403:
        print('🚫 Error 403: Acceso prohibido');
        throw Exception('No tienes permisos para acceder a esta información');
      case 404:
        print('🔍 Error 404: Endpoint no encontrado');
        throw Exception('El servicio no está disponible temporalmente');
      case 500:
        print('💥 Error 500: Fallo del servidor');
        throw Exception('Error interno del servidor');
      default:
        print('❓ Código de estado inesperado: ${response.statusCode}');
        throw Exception(
          'Error del servidor (Código ${response.statusCode})\n'
          'Mensaje: ${response.body.isNotEmpty ? response.body : 'Sin detalles'}'
        );
    }
  }

  static Exception _handleNetworkError(http.ClientException e) {
    final message = e.message.toLowerCase();
    if (message.contains('connection refused')) {
      return Exception('No se puede conectar al servidor. Verifica tu conexión a internet');
    } else if (message.contains('failed host lookup')) {
      return Exception('Problema de DNS. Verifica tu conexión a internet');
    } else {
      return Exception('Error de red: ${e.message}');
    }
  }
}

// Modelo actualizado para referencia
class UserDetail {
  final String username;
  final String? name;
  final String? lastname;
  final Company? company;
  final String? phone;
  final List<dynamic> permission;

  UserDetail({
    required this.username,
    this.name,
    this.lastname,
    this.company,
    this.phone,
    required this.permission,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return UserDetail(
      username: data['username'] as String? ?? '',
      name: data['name'] as String?,
      lastname: data['lastname'] as String?,
      company: data['company'] != null 
          ? Company.fromJson(data['company'] as Map<String, dynamic>)
          : null,
      phone: data['phone'] as String?,
      permission: data['permission'] as List<dynamic>? ?? [],
    );
  }

  String? get fullName => [name, lastname].whereType<String>().join(' ').trim().isNotEmpty 
      ? [name, lastname].whereType<String>().join(' ').trim()
      : null;
}

class Company {
  final String name;

  Company({required this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] as String? ?? 'Sin nombre',
    );
  }
}