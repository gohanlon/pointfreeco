import Database
import Dependencies
import Foundation
import GitHub
import Mailgun
import MemberwiseInit
import Models
import Stripe
import Tagged

public typealias GitHubClientId = GitHub.Client.ID
public typealias GitHubClientSecret = GitHub.Client.Secret

public typealias MailgunApiKey = Mailgun.Client.ApiKey
public typealias MailgunDomain = Mailgun.Client.Domain

public typealias StripeEndpointSecret = Stripe.Client.EndpointSecret
public typealias StripePublishableKey = Stripe.Client.PublishableKey
public typealias StripeSecretKey = Stripe.Client.SecretKey

@MemberwiseInit(.public)
public struct EnvVars: Codable {
  public var appEnv: AppEnv = .development
  public var appSecret: AppSecret = "deadbeefdeadbeefdeadbeefdeadbeef"
  public var baseUrl: URL = URL(string: "http://localhost:8080")!
  public var basicAuth: BasicAuth = BasicAuth()
  public var emergencyMode: Bool = false
  public var gitHub: GitHub = GitHub()
  public var mailgun: Mailgun = Mailgun()
  public var port: Int = 8080
  public var postgres: Postgres = Postgres()
  public var regionalDiscountCouponId: Coupon.ID = "regional-discount"
  public var rssUserAgentWatchlist: [String] = []
  public var slackInviteURL: String = "http://slack.com"
  public var stripe: Stripe = Stripe()
  public var vimeoBearer: String = ""

  private enum CodingKeys: String, CodingKey {
    case appEnv = "APP_ENV"
    case appSecret = "APP_SECRET"
    case baseUrl = "BASE_URL"
    case emergencyMode = "EMERGENCY_MODE"
    case port = "PORT"
    case rssUserAgentWatchlist = "RSS_USER_AGENT_WATCHLIST"
    case regionalDiscountCouponId = "REGIONAL_DISCOUNT_COUPON_ID"
    case slackInviteURL = "PF_COMMUNITY_SLACK_INVITE_URL"
    case vimeoBearer = "VIMEO_BEARER"
  }

  public enum AppEnv: String, Codable {
    case development
    case production
    case staging
    case testing
  }

  @MemberwiseInit(.public)
  public struct BasicAuth: Codable {
    public var username: String = "hello"
    public var password: String = "world"

    private enum CodingKeys: String, CodingKey {
      case username = "BASIC_AUTH_USERNAME"
      case password = "BASIC_AUTH_PASSWORD"
    }
  }

  @MemberwiseInit(.public)
  public struct GitHub: Codable {
    public var clientId: GitHubClientId = "deadbeef-client-id"
    public var clientSecret: GitHubClientSecret = "deadbeef-client-secret"

    private enum CodingKeys: String, CodingKey {
      case clientId = "GITHUB_CLIENT_ID"
      case clientSecret = "GITHUB_CLIENT_SECRET"
    }
  }

  @MemberwiseInit(.public)
  public struct Mailgun: Codable {
    public var apiKey: MailgunApiKey = "key-deadbeefdeadbeefdeadbeefdeadbeef"
    public var domain: MailgunDomain = "mg.domain.com"

    private enum CodingKeys: String, CodingKey {
      case apiKey = "MAILGUN_PRIVATE_API_KEY"
      case domain = "MAILGUN_DOMAIN"
    }
  }

  @MemberwiseInit(.public)
  public struct Postgres: Codable {
    public typealias DatabaseUrl = Tagged<Self, String>

    public var databaseUrl: DatabaseUrl =
      "postgres://pointfreeco:@localhost:5432/pointfreeco_development"

    private enum CodingKeys: String, CodingKey {
      case databaseUrl = "DATABASE_URL"
    }
  }

  @MemberwiseInit(.public)
  public struct Stripe: Codable {
    public var endpointSecret: StripeEndpointSecret = "whsec_test"
    public var publishableKey: StripePublishableKey = "pk_test"
    public var secretKey: StripeSecretKey = "sk_test"

    private enum CodingKeys: String, CodingKey {
      case endpointSecret = "STRIPE_ENDPOINT_SECRET"
      case publishableKey = "STRIPE_PUBLISHABLE_KEY"
      case secretKey = "STRIPE_SECRET_KEY"
    }
  }
}

extension EnvVars {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.appEnv = try container.decode(AppEnv.self, forKey: .appEnv)
    self.appSecret = try container.decode(AppSecret.self, forKey: .appSecret)
    self.baseUrl = try container.decode(URL.self, forKey: .baseUrl)
    self.basicAuth = try .init(from: decoder)
    self.emergencyMode = try container.decodeIfPresent(String.self, forKey: .emergencyMode) == "1"
    self.gitHub = try .init(from: decoder)
    self.mailgun = try .init(from: decoder)
    self.port = Int(try container.decode(String.self, forKey: .port))!
    self.postgres = try .init(from: decoder)
    self.regionalDiscountCouponId = try container.decode(
      Coupon.ID.self, forKey: .regionalDiscountCouponId)
    self.rssUserAgentWatchlist = (try container.decode(String.self, forKey: .rssUserAgentWatchlist))
      .split(separator: ",")
      .map(String.init)
    self.slackInviteURL = try container.decode(String.self, forKey: .slackInviteURL)
    self.stripe = try .init(from: decoder)
    self.vimeoBearer = try container.decode(String.self, forKey: .vimeoBearer)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.appEnv, forKey: .appEnv)
    try container.encode(self.appSecret, forKey: .appSecret)
    try container.encode(self.baseUrl, forKey: .baseUrl)
    try container.encode("\(self.emergencyMode)", forKey: .emergencyMode)
    try self.basicAuth.encode(to: encoder)
    try self.gitHub.encode(to: encoder)
    try self.mailgun.encode(to: encoder)
    try container.encode(String(self.port), forKey: .port)
    try self.postgres.encode(to: encoder)
    try container.encode(
      String(self.rssUserAgentWatchlist.joined(separator: ",")), forKey: .rssUserAgentWatchlist
    )
    try container.encode(self.regionalDiscountCouponId, forKey: .regionalDiscountCouponId)
    try container.encode(self.slackInviteURL, forKey: .slackInviteURL)
    try self.stripe.encode(to: encoder)
    try container.encode(self.vimeoBearer, forKey: .vimeoBearer)
  }
}

extension EnvVars {
  public func assigningValuesFrom(_ env: [String: String]) -> EnvVars {
    let decoded =
      (try? encoder.encode(self))
      .flatMap { try? decoder.decode([String: String].self, from: $0) }
      ?? [:]

    let assigned = decoded.merging(env, uniquingKeysWith: { $1 })

    return (try? JSONSerialization.data(withJSONObject: assigned))
      .flatMap { try? decoder.decode(EnvVars.self, from: $0) }
      ?? self
  }
}

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

extension EnvVars: DependencyKey {
  public static var liveValue: Self {
    let envFilePath = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent(".pf-env")

    let defaultEnvVarDict =
      (try? encoder.encode(EnvVars()))
      .flatMap { try? decoder.decode([String: String].self, from: $0) }
      ?? [:]

    let localEnvVarDict =
      (try? Data(contentsOf: envFilePath))
      .flatMap { try? decoder.decode([String: String].self, from: $0) }
      ?? [:]

    let envVarDict =
      defaultEnvVarDict
      .merging(localEnvVarDict, uniquingKeysWith: { $1 })
      .merging(ProcessInfo.processInfo.environment, uniquingKeysWith: { $1 })

    return (try? JSONSerialization.data(withJSONObject: envVarDict))
      .flatMap { try? decoder.decode(EnvVars.self, from: $0) }
      ?? Self()
  }

  public static var testValue: EnvVars {
    var envVars = EnvVars()
    envVars.appEnv = EnvVars.AppEnv.testing
    envVars.postgres.databaseUrl = "postgres://pointfreeco:@localhost:5432/pointfreeco_test"
    return envVars
  }
}

extension DependencyValues {
  public var envVars: EnvVars {
    get { self[EnvVars.self] }
    set { self[EnvVars.self] = newValue }
  }
}
