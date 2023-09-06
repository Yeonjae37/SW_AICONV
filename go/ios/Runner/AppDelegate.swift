import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)

    GMSServices.provideAPIKey("AIzaSyB-Ga6FzTFIPQ0aH31Wdg2n9yVDoqO9uts")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
