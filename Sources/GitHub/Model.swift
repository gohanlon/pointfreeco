import EmailAddress
import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct AccessToken: Codable {
  public var accessToken: String

  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}

@MemberwiseInit(.public)
public struct OAuthError: Codable {
  public var description: String
  public var error: Error
  public var errorUri: String

  public enum Error: String, Codable {
    /// <https://developer.github.com/apps/managing-oauth-apps/troubleshooting-oauth-app-access-token-request-errors/#bad-verification-code>
    case badVerificationCode = "bad_verification_code"
  }

  private enum CodingKeys: String, CodingKey {
    case description
    case error
    case errorUri = "error_uri"
  }
}

@MemberwiseInit(.public)
public struct GitHubUser: Codable, Identifiable {
  public var createdAt: Date
  public var id: Tagged<Self, Int>
  public var name: String?

  @MemberwiseInit(.public)
  public struct Email: Codable {
    public var email: EmailAddress
    public var primary: Bool
  }

  private enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
    case id
    case name
  }
}

@MemberwiseInit(.public)
public struct GitHubUserEnvelope: Codable {
  public var accessToken: AccessToken
  public var gitHubUser: GitHubUser
}
