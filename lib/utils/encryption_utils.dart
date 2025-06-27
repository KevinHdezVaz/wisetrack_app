import 'dart:convert';

/// Una clase de utilidad para agrupar funciones de codificación y encriptación.
class EncryptionUtils {
  
  /// Convierte un String de texto plano a formato Base64.
  /// 
  /// Base64 no es una encriptación segura, sino una forma de codificar
  /// datos binarios en texto. Es útil para enviar datos que podrían
  /// no ser compatibles con todos los formatos de texto.
  /// 
  /// [plainText] El texto que deseas codificar.
  /// Retorna el [String] codificado en Base64.
  static String toBase64(String plainText) {
    // Convierte el String a una lista de bytes en formato UTF-8
    final bytes = utf8.encode(plainText);
    
    // Codifica la lista de bytes a un String en Base64
    final base64String = base64.encode(bytes);
    
    return base64String;
  }

  // Aquí podrías agregar en el futuro otros métodos, como:
  // static String encryptAES(String text) { ... }
  // static String decryptAES(String text) { ... }

}