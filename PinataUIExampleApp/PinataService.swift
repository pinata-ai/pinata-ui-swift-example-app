import CryptoKit
import Foundation

/// Partner API calls the example needs to log a user in.
/// A real app makes these calls from its backend: the company credentials must never ship in an app.
struct PinataService {
  var baseURL = URL(string: "https://sandbox.pinata.ai/partners/api/v1/")!

  func getCompanyToken(clientId: String, clientKey: String, clientSecret: String) async throws -> String {
    let payload = try JSONSerialization.data(withJSONObject: ["clientId": clientId, "clientKey": clientKey])
    return try await post(
      "auth/retrieve-token/", body: payload, headers: ["Signature": sign(payload, secret: clientSecret)])
  }

  func getUserToken(companyAccessToken: String, userEmail: String) async throws -> String {
    let payload = try JSONSerialization.data(withJSONObject: ["email": userEmail])
    return try await post(
      "auth/retrieve-user-token/", body: payload, headers: ["Authorization": "Token \(companyAccessToken)"])
  }

  private func sign(_ payload: Data, secret: String) -> String {
    let key = SymmetricKey(data: Data(secret.utf8))
    return Data(HMAC<SHA256>.authenticationCode(for: payload, using: key)).base64EncodedString()
  }

  /// Posts `body` and returns `data.accessToken` from the response.
  private func post(_ path: String, body: Data, headers: [String: String]) async throws -> String {
    var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
    request.httpMethod = "POST"
    request.httpBody = body
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    for (name, value) in headers { request.setValue(value, forHTTPHeaderField: name) }

    let (data, response) = try await URLSession.shared.data(for: request)
    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    guard (200..<300).contains(status) else { throw ServiceError.http(path, status) }
    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
      let token = (json["data"] as? [String: Any])?["accessToken"] as? String
    else { throw ServiceError.noToken(path) }
    return token
  }
}

enum ServiceError: LocalizedError {
  case http(String, Int)
  case noToken(String)

  var errorDescription: String? {
    switch self {
    case .http(let path, let status): return "\(path) failed with HTTP \(status)"
    case .noToken(let path): return "\(path) returned no access token"
    }
  }
}
