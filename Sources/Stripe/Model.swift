import Either
import Foundation
import MemberwiseInit
import Tagged
import TaggedMoney

public typealias Expandable<Field: Identifiable> = Either<Field.ID, Field>

extension Either where R: Identifiable, L == R.ID {
  public var id: R.ID { self.either({ $0 }, \.id) }
}

public typealias StripeID<Field> = Tagged<Field, String>

public protocol CardProtocol {
  var cardBrand: Card.Brand { get }
  var expMonth: Int { get }
  var expYear: Int { get }
  var last4: String { get }
}
extension Card: CardProtocol {
  public var cardBrand: Brand { self.brand }
}
extension PaymentMethod.Card: CardProtocol {
  public var cardBrand: Card.Brand {
    switch self.brand {
    case .amex:
      return .americanExpress
    case .diners:
      return .dinersClub
    case .discover:
      return .discover
    case .jcb:
      return .jcb
    case .mastercard:
      return .masterCard
    case .unionpay:
      return .unionPay
    case .visa:
      return .visa
    }
  }
}
extension Source.Card: CardProtocol {
  public var cardBrand: Card.Brand { self.brand }
  public var cardCountry: Country? { self.country }
}

@MemberwiseInit(.public)
public struct Card: Codable, Equatable, Identifiable {
  public var brand: Brand
  public var country: Country?
  public var expMonth: Int
  public var expYear: Int
  public var id: StripeID<Self>
  public var last4: String
  public var object: Object

  public enum Object: String, Codable { case card }

  public enum Brand: String, Codable, Equatable {
    case visa = "Visa"
    case americanExpress = "American Express"
    case masterCard = "MasterCard"
    case discover = "Discover"
    case jcb = "JCB"
    case dinersClub = "Diners Club"
    case unknown = "Unknown"
    case unionPay = "UnionPay"
  }

  public enum Funding: String, Codable {
    case credit
    case debit
    case prepaid
    case unknown
  }
}

@MemberwiseInit(.public)
public struct Charge: Codable, Equatable, Identifiable {
  public var amount: Cents<Int>
  public var id: StripeID<Self>
  public var paymentMethodDetails: PaymentMethodDetails

  @MemberwiseInit(.public)
  public struct PaymentMethodDetails: Codable, Equatable {
    public var card: PaymentMethod.Card? = nil
  }
}

//@MemberwiseInit(.public)  // 🛑 Circular reference resolving attached macro 'MemberwiseInit'
public struct Coupon: Equatable, Identifiable {
  public var duration: Duration
  public var id: StripeID<Self>
  public var name: String?
  public var rate: Rate
  public var valid: Bool

  public init(duration: Duration, id: ID, name: String?, rate: Rate, valid: Bool) {
    self.duration = duration
    self.id = id
    self.name = name
    self.rate = rate
    self.valid = valid
  }

  public func discount(for cents: Cents<Int>) -> Cents<Int> {
    switch self.rate {
    case let .amountOff(amountOff):
      return cents - amountOff
    case let .percentOff(percentOff):
      return cents.map { cents -> Int in
        let discountPercent = Double(100 - percentOff) / 100
        return Int(round(Double(cents) * discountPercent))
      }
    }
  }

  public var formattedDescription: String {
    switch duration {
    case .forever:
      return "\(self.rate.formattedDescription) every billing period"
    case .once:
      return "\(self.rate.formattedDescription) the first billing period"
    case let .repeating(months: months):
      return "\(self.rate.formattedDescription) every billing period for the first \(months) months"
    }
  }

  public enum Duration: Equatable {
    case forever
    case once
    case repeating(months: Int)
  }

  public enum Rate: Equatable {
    case amountOff(Cents<Int>)
    case percentOff(Int)

    public var formattedDescription: String {
      switch self {
      case let .amountOff(amountOff):
        return "$\(Int(amountOff.map(Double.init).dollars.rawValue)) off"
      case let .percentOff(percentOff):
        return "\(percentOff)% off"
      }
    }
  }
}

//@MemberwiseInit(.public)  // 🛑 Circular reference resolving attached macro 'MemberwiseInit'
public struct Source: Codable, Equatable, Identifiable {
  public var id: StripeID<Self>
  public var card: Card? = nil
  public var object: Object

  public enum Object: String, Codable { case source }

  public init(id: ID, card: Card? = nil, object: Object) {
    self.id = id
    self.card = card
    self.object = object
  }

  // Note: Before @MemberwiseInit, manual `init` had non-optional `country: Country` parameter for optional property. Deliberate?
  @MemberwiseInit(.public)
  public struct Card: Codable, Equatable {
    public var brand: Stripe.Card.Brand
    public var country: Country?
    public var expMonth: Int
    public var expYear: Int
    public var last4: String
  }
}

public enum Currency: String, Codable {
  case usd
}

@MemberwiseInit(.public)
public struct Customer: Codable, Equatable, Identifiable {
  public var balance: Cents<Int>
  public var businessVatId: Vat?
  public var defaultSource: Either<Expandable<Card>, Expandable<Source>>?
  public var id: StripeID<Self>
  public var invoiceSettings: InvoiceSettings
  public var metadata: [String: String]

  public var defaultCard: (any CardProtocol)? {
    self.defaultSource?.either({ $0.right }, { $0.right?.card })
  }

  public typealias Vat = Tagged<(Self, vat: ()), String>

  public var extraInvoiceInfo: String? {
    return self.metadata["extraInvoiceInfo"]
  }

  @MemberwiseInit(.public)
  public struct InvoiceSettings: Codable, Equatable {
    public var defaultPaymentMethod: PaymentMethod.ID?
  }

  public var hasPaymentInfo: Bool {
    self.invoiceSettings.defaultPaymentMethod != nil || self.defaultSource != nil
  }
}

@MemberwiseInit(.public)
public struct Discount: Codable, Equatable {
  public var coupon: Coupon
}

@MemberwiseInit(.public)
public struct StripeErrorEnvelope: Codable, Error {
  public var error: StripeError
}

@MemberwiseInit(.public)
public struct StripeError: Codable, Error {
  public var message: String
}

@MemberwiseInit(.public)
public struct Event<T: Codable & Equatable>: Equatable, Codable, Identifiable {
  public var data: Data
  public var id: StripeID<Self>
  public var type: `Type`

  @MemberwiseInit(.public)
  public struct Data: Codable, Equatable {
    public var object: T
  }

  public enum `Type`: String, Codable, Equatable {
    case customerSubscriptionDeleted = "customer.subscription.deleted"
    case invoicePaymentFailed = "invoice.payment_failed"
    case invoicePaymentSucceeded = "invoice.payment_succeeded"
    case paymentIntentPaymentFailed = "payment_intent.payment_failed"
    case paymentIntentSucceeded = "payment_intent.succeeded"
  }
}

@MemberwiseInit(.public)
public struct Invoice: Codable, Equatable {
  public typealias ID = StripeID<Self>

  public var amountDue: Cents<Int>
  public var amountPaid: Cents<Int>
  public var charge: Expandable<Charge>?
  public var created: Date
  public var customer: Customer.ID
  public var discount: Discount?
  public var id: ID?
  public var invoicePdf: String?
  public var lines: ListEnvelope<LineItem>
  public var number: Number?
  public var paymentIntent: Expandable<PaymentIntent>?
  public var periodStart: Date
  public var periodEnd: Date
  public var status: Status
  public var subscription: Subscription.ID?
  public var subtotal: Cents<Int>
  public var total: Cents<Int>

  public typealias Number = Tagged<(Self, number: ()), String>

  public enum Status: String, Codable {
    case draft
    case open
    case void
    case paid
    case uncollectible
  }
}

@MemberwiseInit(.public)
public struct LineItem: Codable, Equatable, Identifiable {
  public var amount: Cents<Int>
  public var description: String?
  public var id: StripeID<Self>
  public var plan: Plan?
  public var quantity: Int
  public var subscription: Subscription.ID?
}

@MemberwiseInit(.public)
public struct ListEnvelope<A: Codable & Equatable>: Codable, Equatable {
  public var data: [A]
  public var hasMore: Bool
}

@MemberwiseInit(.public)
public struct PaymentIntent: Codable, Equatable, Identifiable {
  public var amount: Cents<Int>
  public var clientSecret: ClientSecret
  public var currency: Currency
  public var id: StripeID<Self>
  public var status: Status

  public typealias ClientSecret = Tagged<(Self, secret: ()), String>

  public enum Status: String, Codable, Equatable {
    case requiresPaymentMethod = "requires_payment_method"
    case requiresConfirmation = "requires_confirmation"
    case requiresAction = "requires_action"
    case processing
    case requiresCapture = "requires_capture"
    case canceled
    case succeeded
  }
}

public enum CountryTag {}
public typealias Country = Tagged<CountryTag, String>

//@MemberwiseInit(.public)  // 🛑 Circular reference resolving attached macro 'MemberwiseInit'
public struct PaymentMethod: Codable, Equatable, Identifiable {
  public var card: Card? = nil
  public var customer: Expandable<Customer>? = nil
  public var id: StripeID<Self>

  public init(
    card: Card? = nil,
    customer: Expandable<Customer>? = nil,
    id: ID
  ) {
    self.card = card
    self.customer = customer
    self.id = id
  }

  @MemberwiseInit(.public)
  public struct Card: Codable, Equatable {
    public var brand: Brand
    public var country: Country
    public var expMonth: Int
    public var expYear: Int
    public var funding: Funding
    public var last4: String

    public enum Brand: String, Codable, Equatable {
      case amex
      case diners
      case discover
      case jcb
      case mastercard
      case unionpay
      case visa

      public var description: String {
        switch self {
        case .amex:
          return "American Express"
        case .diners:
          return "Diner's Club"
        case .discover:
          return "Discover"
        case .jcb:
          return "JCB"
        case .mastercard:
          return "MasterCard"
        case .unionpay:
          return "UnionPay"
        case .visa:
          return "Visa"
        }
      }
    }

    public enum Funding: String, Codable, Equatable {
      case credit
      case debit
      case prepaid
      case unknown
    }
  }
}

@MemberwiseInit(.public)
public struct Plan: Codable, Equatable, Identifiable {
  public var created: Date
  public var currency: Currency
  public var id: StripeID<Self>
  public var interval: Interval
  public var metadata: [String: String]
  public var nickname: String?

  public enum Interval: String, Codable {
    case month
    case year
  }

  public var description: String {
    self.nickname ?? self.id.rawValue
  }
}

@MemberwiseInit(.public)
public struct Subscription: Codable, Equatable, Identifiable {
  public var canceledAt: Date?
  public var cancelAtPeriodEnd: Bool
  public var created: Date
  public var currentPeriodStart: Date
  public var currentPeriodEnd: Date
  public var customer: Expandable<Customer>
  public var discount: Discount?
  public var endedAt: Date?
  public var id: StripeID<Self>
  public var items: ListEnvelope<Item>
  public var latestInvoice: Either<Invoice.ID, Invoice>?
  public var plan: Plan
  public var quantity: Int
  public var startDate: Date
  public var status: Status

  public var isCanceling: Bool {
    return self.status == .active && self.cancelAtPeriodEnd
  }

  public var isCancellable: Bool {
    return (self.status == .active || self.status == .pastDue) && !self.cancelAtPeriodEnd
  }

  public var isRenewing: Bool {
    return self.status != .canceled && !self.cancelAtPeriodEnd
  }

  @MemberwiseInit(.public)
  public struct Item: Codable, Equatable, Identifiable {
    public typealias ID = StripeID<Self>

    public var created: Date
    public var id: ID
    public var plan: Plan
    public var quantity: Int
  }

  public enum Status: String, Codable {
    case active
    case canceled
    case incomplete
    case incompleteExpired = "incomplete_expired"
    case pastDue = "past_due"
    case paused
    case trialing
    case unpaid

    public var isActive: Bool {
      switch self {
      case .active, .trialing:
        return true
      case .canceled, .incomplete, .incompleteExpired, .pastDue, .paused, .unpaid:
        return false
      }
    }

    public var isIncomplete: Bool {
      switch self {
      case .incomplete, .incompleteExpired:
        return true
      case .active, .canceled, .pastDue, .paused, .trialing, .unpaid:
        return false
      }
    }
  }
}

extension Coupon.Rate: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let amountOff = try? container.decode(Cents<Int>.self, forKey: .amountOff) {
      self = .amountOff(amountOff)
    } else {
      self = try .percentOff(container.decode(Int.self, forKey: .percentOff))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .amountOff(cents):
      try container.encode(cents, forKey: .amountOff)
    case let .percentOff(percent):
      try container.encode(percent, forKey: .percentOff)
    }
  }

  public var amountOff: Cents<Int>? {
    guard case let .amountOff(cents) = self else { return nil }
    return cents
  }

  public var percentOff: Int? {
    guard case let .percentOff(percent) = self else { return nil }
    return percent
  }

  private enum CodingKeys: String, CodingKey {
    case amountOff
    case percentOff
  }
}

extension Coupon.Duration: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let durationKey = try container.decode(DurationKey.self, forKey: .duration)
    switch durationKey {
    case .forever:
      self = .forever
    case .once:
      self = .once
    case .repeating:
      let months = try container.decode(Int.self, forKey: .durationInMonths)
      self = .repeating(months: months)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .forever:
      try container.encode(DurationKey.forever, forKey: .duration)
    case .once:
      try container.encode(DurationKey.once, forKey: .duration)
    case let .repeating(months):
      try container.encode(DurationKey.repeating, forKey: .duration)
      try container.encode(months, forKey: .durationInMonths)
    }
  }

  private enum DurationKey: String, Codable {
    case forever
    case once
    case repeating
  }

  private enum CodingKeys: String, CodingKey {
    case duration
    case durationInMonths
  }
}

extension Coupon: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.init(
      duration: try Coupon.Duration(from: decoder),
      id: try container.decode(Coupon.ID.self, forKey: .id),
      name: try container.decodeIfPresent(String.self, forKey: .name),
      rate: try Coupon.Rate(from: decoder),
      valid: try container.decode(Bool.self, forKey: .valid)
    )
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try self.duration.encode(to: encoder)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.name, forKey: .name)
    try self.rate.encode(to: encoder)
    try container.encode(self.valid, forKey: .valid)
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case valid
  }
}

extension Tagged<Plan, String> {
  public static let monthly: Self = "monthly-2019"
  public static var yearly: Self = "yearly-2019"
}
