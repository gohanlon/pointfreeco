import EmailAddress
import MemberwiseInit
import Stripe

@MemberwiseInit(.public)
public struct SubscribeData: Equatable {
  public var coupon: Coupon.ID?
  public var isOwnerTakingSeat: Bool
  public var paymentMethodID: PaymentMethod.ID
  public var pricing: Pricing
  public var referralCode: User.ReferralCode?
  public var subscriptionID: Stripe.Subscription.ID?
  public var teammates: [EmailAddress]
  public var useRegionalDiscount: Bool

  public enum CodingKeys: String, CodingKey {
    case coupon
    case isOwnerTakingSeat
    case paymentMethodID
    case pricing
    case referralCode = "ref"
    case subscriptionID
    case teammates
    case useRegionalDiscount
  }
}
