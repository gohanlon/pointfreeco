import EmailAddress
import MemberwiseInit

// NB: remove this `Encodable` to get a runtime crash
@MemberwiseInit(.public)
public struct ProfileData: Encodable, Equatable {
  public let email: EmailAddress
  public let extraInvoiceInfo: String?
  public let emailSettings: [String: String]
  public let name: String?

  public enum CodingKeys: String, CodingKey {
    case email
    case extraInvoiceInfo
    case emailSettings
    case name
  }
}

extension ProfileData: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.email = try container.decode(EmailAddress.self, forKey: .email)
    self.emailSettings =
      (try? container.decode([String: String].self, forKey: .emailSettings)) ?? [:]
    self.extraInvoiceInfo = try? container.decode(String.self, forKey: .extraInvoiceInfo)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
  }
}
