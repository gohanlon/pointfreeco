import Either
import EmailAddress
import Foundation
import GitHub
import MemberwiseInit
import Stripe
import Tagged

@MemberwiseInit(.public)
public struct User: Decodable, Equatable, Identifiable {
  public var email: EmailAddress
  public var episodeCreditCount: Int
  public var gitHubUserId: GitHubUser.ID
  public var gitHubAccessToken: String
  public var id: Tagged<Self, UUID>
  public var isAdmin: Bool
  public var name: String?
  public var referralCode: ReferralCode
  public var referrerId: ID?
  public var rssSalt: RssSalt
  public var subscriptionId: Subscription.ID?

  public typealias ReferralCode = Tagged<(Self, referralCode: ()), String>
  public typealias RssSalt = Tagged<(Self, rssSalt: ()), String>

  public enum CodingKeys: String, CodingKey {
    case email
    case episodeCreditCount = "episode_credit_count"
    case gitHubUserId = "github_user_id"
    case gitHubAccessToken = "github_access_token"
    case id
    case isAdmin = "is_admin"
    case name
    case rssSalt = "rss_salt"
    case referralCode = "referral_code"
    case referrerId = "referrer_id"
    case subscriptionId = "subscription_id"
  }

  public enum SubscriberState {
    case nonSubscriber
    case subscriber
  }

  public var displayName: String {
    return name ?? email.rawValue
  }

  public var gitHubAvatarUrl: URL {
    return URL(
      string: "https://avatars0.githubusercontent.com/u/\(self.gitHubUserId.rawValue)?v=4")!
  }
}
