import Flutter
import UIKit
import GoogleMaps  // ¡Esta línea es crucial!

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configura tu API Key de Google Maps
    GMSServices.provideAPIKey("AIzaSyDUr9LlEWbsDFQveRGQhh_tSO_Fxk65GYY")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}