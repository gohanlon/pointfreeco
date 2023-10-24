import EmailAddress
import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct TeamInvite: Decodable, Equatable, Identifiable {
  public var createdAt: Date
  public var email: EmailAddress
  public var id: Tagged<Self, UUID>
  public var inviterUserId: User.ID
}
