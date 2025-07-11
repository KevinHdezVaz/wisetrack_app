import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
// 1. Importa el paquete dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Clase que carga las opciones de Firebase desde un archivo .env
/// para la plataforma actual (iOS o Android).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // La configuración para Web no fue proporcionada.
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // 2. Lee las variables de entorno para Android
        return FirebaseOptions(
          apiKey: dotenv.env['ANDROID_API_KEY']!,
          appId: dotenv.env['ANDROID_APP_ID']!,
          messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
          projectId: dotenv.env['PROJECT_ID']!,
          storageBucket: dotenv.env['STORAGE_BUCKET']!,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // 3. Lee las variables de entorno para iOS/macOS
        return FirebaseOptions(
          apiKey: dotenv.env['IOS_API_KEY']!,
          appId: dotenv.env['IOS_APP_ID']!,
          messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
          projectId: dotenv.env['PROJECT_ID']!,
          storageBucket: dotenv.env['STORAGE_BUCKET']!,
          iosBundleId: dotenv.env['IOS_BUNDLE_ID']!,
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
