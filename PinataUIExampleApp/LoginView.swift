import SwiftUI

/// Gets a user token the way a partner backend would: company token first, then the user's token.
struct LoginView: View {
  @EnvironmentObject private var session: Session
  @State private var clientId = Config.clientId
  @State private var clientKey = Config.clientKey
  @State private var clientSecret = Config.clientSecret
  @State private var userEmail = Config.userEmail
  @State private var loggingIn = false
  @State private var error: String?

  var body: some View {
    NavigationStack {
      Form {
        Section("Company") {
          TextField("Client ID", text: $clientId)
          TextField("Client key", text: $clientKey)
          SecureField("Client secret", text: $clientSecret)
        }
        Section("User") {
          TextField("User email", text: $userEmail)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
        }
        Button(loggingIn ? "Logging in..." : "Login") { Task { await login() } }
          .disabled(loggingIn)
      }
      .autocorrectionDisabled()
      .navigationTitle("Pinata UI example")
      .alert("Login failed", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(error ?? "")
      }
    }
  }

  private func login() async {
    let fields = [clientId, clientKey, clientSecret, userEmail].map { $0.trimmingCharacters(in: .whitespaces) }
    if fields.contains(where: \.isEmpty) {
      error = "All fields are required"
      return
    }
    loggingIn = true
    defer { loggingIn = false }
    do {
      let service = PinataService()
      let companyToken = try await service.getCompanyToken(
        clientId: fields[0], clientKey: fields[1], clientSecret: fields[2])
      let userToken = try await service.getUserToken(companyAccessToken: companyToken, userEmail: fields[3])
      session.login(userToken: userToken)
    } catch {
      self.error = error.localizedDescription
    }
  }
}
