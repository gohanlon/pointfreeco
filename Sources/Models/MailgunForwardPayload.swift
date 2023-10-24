import EmailAddress
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct MailgunForwardPayload: Codable, Equatable {
  public let recipient: EmailAddress
  public let timestamp: Int
  public let token: String
  public let sender: EmailAddress
  public let signature: String
}
