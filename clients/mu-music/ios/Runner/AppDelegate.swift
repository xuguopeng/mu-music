import Flutter
import UIKit
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "cookie_channel", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard call.method == "getCookies" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: Any], let urlString = args["url"] as? String, let url = URL(string: urlString) else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "url is required", details: nil))
        return
      }

      // Try to gather cookies from HTTPCookieStorage (NSURLConnection/URLSession layer)
      var cookieMap: [String: String] = [:]
      if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
        for cookie in cookies {
          cookieMap[cookie.name] = cookie.value
        }
      }

      // Additionally attempt to read from WKWebView data store (best-effort)
      if #available(iOS 11.0, *) {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.httpCookieStore.getAllCookies { cookies in
          for cookie in cookies where cookie.domain.contains(url.host ?? "") {
            cookieMap[cookie.name] = cookie.value
          }
          result(cookieMap)
        }
      } else {
        result(cookieMap)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
