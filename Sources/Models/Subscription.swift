import Foundation
import MemberwiseInit
import Stripe
import Tagged

@MemberwiseInit(.public)
public struct Subscription: Decodable, Identifiable {
  public var deactivated: Bool
  public var id: Tagged<Self, UUID>
  public var stripeSubscriptionId: Stripe.Subscription.ID
  public var stripeSubscriptionStatus: Stripe.Subscription.Status
  public var teamInviteCode: TeamInviteCode
  public var userId: User.ID

  public typealias TeamInviteCode = Tagged<(Self, teamInviteCode: ()), String>
}

extension Tagged where Tag == (Subscription, teamInviteCode: ()), RawValue == String {
  public var isDomain: Bool {
    self.rawValue.contains(".")
  }
}
