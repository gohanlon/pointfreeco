import EmailAddress
import MemberwiseInit
import Stripe

@MemberwiseInit(.public)
public struct SubscribeConfirmationData: Equatable {
  public var billing: Pricing.Billing
  public var isOwnerTakingSeat: Bool
  public var referralCode: User.ReferralCode?
  public var teammates: [EmailAddress]
  public var useRegionalDiscount: Bool
}
