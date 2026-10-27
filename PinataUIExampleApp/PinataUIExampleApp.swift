import SwiftUI

@main
struct PinataUIExampleApp: App {
  @StateObject private var session = Session()

  var body: some Scene {
    WindowGroup {
      Group {
        if session.userToken == nil { LoginView() } else { MainView() }
      }
      .environmentObject(session)
    }
  }
}

/// Values from Config.xcconfig, through Info.plist. Empty when the file is missing.
enum Config {
  static let clientId = value("PinataClientId")
  static let clientKey = value("PinataClientKey")
  static let clientSecret = value("PinataClientSecret")
  static let userEmail = value("PinataUserEmail")

  private static func value(_ key: String) -> String {
    Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
  }
}
