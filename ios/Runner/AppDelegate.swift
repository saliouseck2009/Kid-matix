import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludeDocumentsFromBackup()
    // Lets the daily reminder show while the app is open (F18).
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Keeps the players' data out of the iCloud backup: nothing leaves the
  /// phone (specifications, section 16). The database lives in Documents.
  private func excludeDocumentsFromBackup() {
    guard var documents = FileManager.default.urls(
      for: .documentDirectory, in: .userDomainMask
    ).first else { return }
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? documents.setResourceValues(values)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
