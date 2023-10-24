import EmailAddress
import Foundation
import MemberwiseInit
import Stripe
import Tagged

@MemberwiseInit(.public)
public struct Gift: Decodable, Identifiable {
  public var deliverAt: Date?
  public var delivered: Bool
  public var fromEmail: EmailAddress
  public var fromName: String
  public var id: Tagged<Self, UUID>
  public var message: String
  public var monthsFree: Int
  public var stripePaymentIntentId: PaymentIntent.ID
  public var stripePaymentIntentStatus: PaymentIntent.Status
  public var stripeSubscriptionId: Stripe.Subscription.ID?
  public var toEmail: EmailAddress
  public var toName: String
}
