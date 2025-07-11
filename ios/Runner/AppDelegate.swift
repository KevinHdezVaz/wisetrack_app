import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1. Inicializa Firebase. Esto SIEMPRE debe ser lo primero.
    FirebaseApp.configure()

    // 2. Configura Google Maps con tu API Key
    // Reemplaza "TU_API_KEY_DE_GOOGLE_MAPS" con tu clave real
    GMSServices.provideAPIKey("AIzaSyAjWmOkK435ZzSYvaG_C1lSZU3ZIkjhLSE")

    // 3. Registra los plugins de Flutter.
    // Esto permite que plugins como Maps_flutter y firebase_messaging
    // se configuren correctamente en el lado nativo.
    GeneratedPluginRegistrant.register(with: self)

    // 4. Configura el delegado para notificaciones de Firebase.
    Messaging.messaging().delegate = self
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  // MARK: - Métodos para Notificaciones Push

  override func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Convierte el token de Data a String para poder imprimirlo y depurar.
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let tokenString = tokenParts.joined()
    // AÑADIDO: Prefijo "TOKEN_APNS:" para búsqueda fácil.
    print("TOKEN_APNS: ✅ Token de dispositivo Apple (APNs) recibido: \(tokenString)")

    print("✅ Asignando token de APNs a Firebase Messaging...")
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(_ application: UIApplication, 
                didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Error al registrar para notificaciones remotas: \(error.localizedDescription)")
  }
}

// MARK: - Firebase Messaging Delegate

extension AppDelegate: MessagingDelegate {
    // Este método se llama cuando Firebase genera o actualiza el token de FCM.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // AÑADIDO: Prefijo "TOKEN_FCM:" para búsqueda fácil.
        print("TOKEN_FCM: 🔑 Token de registro de Firebase (FCM) recibido: \(String(describing: fcmToken))")
        
        // El plugin de Flutter se encarga de manejar este token.
        // La línea que causaba el error fue eliminada.
        // El NotificationCenter se mantiene por si lo usas en otra parte.
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}