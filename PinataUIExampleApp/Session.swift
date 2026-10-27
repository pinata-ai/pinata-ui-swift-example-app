import Foundation

/// The logged-in user's token, kept across launches (the React Native example uses AsyncStorage).
final class Session: ObservableObject {
  private static let key = "logged-in-user"

  @Published private(set) var userToken: String? = UserDefaults.standard.string(forKey: Session.key)

  func login(userToken: String) {
    UserDefaults.standard.set(userToken, forKey: Session.key)
    self.userToken = userToken
  }

  func logout() {
    UserDefaults.standard.removeObject(forKey: Session.key)
    userToken = nil
  }
}
