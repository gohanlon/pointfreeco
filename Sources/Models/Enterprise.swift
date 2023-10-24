import EmailAddress
import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct EnterpriseAccount: Decodable, Equatable, Identifiable {
  public var companyName: String
  public var domain: Domain
  public var id: Tagged<Self, UUID>
  public var subscriptionId: Subscription.ID

  public typealias Domain = Tagged<Self, String>
}

@MemberwiseInit(.public)
public struct EnterpriseEmail: Decodable, Equatable, Identifiable {
  public var id: Tagged<Self, UUID>
  public var email: EmailAddress
  public var userId: User.ID
}

@MemberwiseInit(.public)
public struct EnterpriseRequestFormData: Codable, Equatable {
  public var email: EmailAddress

  public enum CodingKeys: String, CodingKey {
    case email
  }
}
