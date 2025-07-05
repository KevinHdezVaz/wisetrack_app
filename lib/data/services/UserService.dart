import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // For temporary file storage
import 'package:wisetrack_app/data/models/User/UserDetail.dart';
import 'package:wisetrack_app/data/models/alert/NotificationPermissions.dart';
import 'package:wisetrack_app/data/services/UserCacheService.dart';
import 'package:wisetrack_app/utils/TokenStorage.dart';
import 'package:wisetrack_app/utils/constants.dart';

// Custom Log class for logging
class Log {
  static void e(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    final logMessage = '[ERROR] $tag: $message${error != null ? ' | Error: $error' : ''}${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}';
    debugPrint(logMessage);
  }

  static void i(String tag, String message) {
    debugPrint('[INFO] $tag: $message');
  }

  static void d(String tag, String message) {
    debugPrint('[DEBUG] $tag: $message');
  }
}

class UserService {
  static const String _tag = 'UserService';

  static Future<UserDetailResponse> getUserDetail() async {
  Log.i(_tag, 'Starting getUserDetail request');

  final token = await _getTokenWithValidation();
  final url = Uri.parse('${Constants.baseUrl}/user/detail');
  final headers = {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Log.d(_tag, 'Requesting URL: $url with headers: $headers');

  try {
    final response = await http.get(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    Log.i(_tag, 'Received response with status: ${response.statusCode}');

    if (response.statusCode == 200) {
      Log.d(_tag, 'Response body: ${response.body}');

      // --- CORRECCIÓN ---

      // 1. Primero, decodifica la respuesta y CREA el objeto.
      final userDetailResponse = UserDetailResponse.fromJson(json.decode(response.body));

      // 2. Ahora que 'userDetailResponse' existe, úsalo para guardar en la caché.
      await UserCacheService.saveUserData(userDetailResponse.data);

      // 3. Finalmente, devuelve el objeto que ya creaste.
      return userDetailResponse;

    } else {
      throw _handleErrorResponse(response);
    }
  } on http.ClientException catch (e, stackTrace) {
    // Si la red falla, intenta cargar desde la caché (como lo teníamos antes)
    Log.e(_tag, 'Network request failed. Attempting to load from cache.', e, stackTrace);
    final cachedUser = await UserCacheService.getCachedUserData();
    if (cachedUser != null) {
      return UserDetailResponse(data: cachedUser);
    } else {
      Log.e(_tag, 'Failed to load from network and no data in cache.');
      throw Exception('No se pudo conectar al servidor y no hay datos locales.');
    }
  } on TimeoutException catch (e, stackTrace) {
    Log.e(_tag, 'Request timed out after 15 seconds', e, stackTrace);
    throw Exception('El servidor no respondió a tiempo');
  } catch (e, stackTrace) {
    Log.e(_tag, 'Unexpected error: $e', e, stackTrace);
    throw Exception('Error desconocido: $e');
  }
}

  static Future<UserDetailResponse> updateUserProfile({
    required String username,
    required String name,
    required String company,
    required dynamic image, // Changed to dynamic to handle File or String (URL)
    String? lastname,
    String? phone,
  }) async {
    Log.i(_tag, 'Starting updateUserProfile request');

    final token = await _getTokenWithValidation();
    final url = Uri.parse('${Constants.baseUrl}/user/update');

    try {
      // Validate and prepare the image file
      File imageFile;
      if (image is File) {
        // Check if the file exists
        if (!await image.exists()) {
          Log.e(_tag, 'Image file does not exist: ${image.path}');
          throw Exception('Image file does not exist');
        }
        imageFile = image;
      } else if (image is String && Uri.parse(image).isAbsolute) {
        // Handle URL: Download the image to a temporary file
        Log.i(_tag, 'Downloading image from URL: $image');
        imageFile = await _downloadImage(image);
      } else {
        Log.e(_tag, 'Invalid image parameter: $image');
        throw Exception('Image must be a File or a valid URL');
      }

      Log.d(_tag, 'Preparing multipart request for URL: $url');
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Token $token'
        ..fields['username'] = username
        ..fields['name'] = name
        ..fields['company'] = company
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      if (lastname != null) {
        request.fields['lastname'] = lastname;
        Log.d(_tag, 'Added lastname to request: $lastname');
      }
      if (phone != null) {
        request.fields['phone'] = phone;
        Log.d(_tag, 'Added phone to request: $phone');
      }

      Log.d(_tag, 'Sending multipart request with fields: ${request.fields}');
      final response = await request.send()
          .timeout(const Duration(seconds: 20));
      final responseBody = await response.stream.bytesToString();

      Log.i(_tag, 'Received response with status: ${response.statusCode}');
      Log.d(_tag, 'Response body: $responseBody');

      if (response.statusCode == 200) {
        return UserDetailResponse.fromJson(json.decode(responseBody));
      } else {
        throw _handleErrorResponse(
          http.Response(responseBody, response.statusCode)
        );
      }
    } on SocketException catch (e, stackTrace) {
      Log.e(_tag, 'SocketException occurred: ${e.message}', e, stackTrace);
      throw Exception('Error de conexión: ${e.message}');
    } on TimeoutException catch (e, stackTrace) {
      Log.e(_tag, 'Request timed out after 20 seconds', e, stackTrace);
      throw Exception('El servidor no respondió a tiempo');
    } catch (e, stackTrace) {
      Log.e(_tag, 'Error updating profile: $e', e, stackTrace);
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Utility to download an image from a URL to a temporary file
  static Future<File> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        Log.e(_tag, 'Failed to download image from $url, status: ${response.statusCode}');
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = url.split('/').last;
      final tempFile = File('${tempDir.path}/$fileName');

      // Write the image data to the file
      await tempFile.writeAsBytes(response.bodyBytes);
      Log.d(_tag, 'Image downloaded and saved to: ${tempFile.path}');
      return tempFile;
    } catch (e, stackTrace) {
      Log.e(_tag, 'Error downloading image from $url', e, stackTrace);
      rethrow;
    }
  }

  static Future<String> _getTokenWithValidation() async {
    Log.i(_tag, 'Fetching token from TokenStorage');
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      Log.e(_tag, 'Invalid or missing token');
      throw Exception('Authentication required: Invalid token');
    }
    Log.d(_tag, 'Token retrieved successfully');
    return token;
  }

  static Exception _handleNetworkError(http.ClientException e) {
    final message = e.message.toLowerCase();
    Log.e(_tag, 'Handling network error: $message');
    if (message.contains('connection refused')) {
      return Exception('No se puede conectar al servidor. Verifica tu conexión a internet');
    } else if (message.contains('failed host lookup')) {
      return Exception('Problema de DNS. Verifica tu conexión a internet');
    } else {
      return Exception('Error de red: ${e.message}');
    }
  }

  static Exception _handleErrorResponse(http.Response response) {
    Log.e(_tag, 'Handling error response with status: ${response.statusCode}');
    try {
      final error = json.decode(response.body)['error'] ?? 'Error desconocido';
      Log.d(_tag, 'Error message from server: $error');
      return Exception('${response.statusCode}: $error');
    } catch (e, stackTrace) {
      Log.e(_tag, 'Failed to parse error response: $e', e, stackTrace);
      return Exception('Error ${response.statusCode}');
    }
  }
}
 