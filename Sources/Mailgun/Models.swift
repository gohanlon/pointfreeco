import EmailAddress
import MemberwiseInit

@MemberwiseInit(.public)
public struct SendEmailResponse: Decodable {
  public let id: String
  public let message: String
}

public enum Tracking: String {
  case no
  case yes
}

public enum TrackingClicks: String {
  case yes
  case no
  case htmlOnly = "htmlonly"
}

public enum TrackingOpens: String {
  case yes
  case no
  case htmlOnly = "htmlonly"
}

@MemberwiseInit(.public)
public struct Email {
  public var from: EmailAddress
  public var to: [EmailAddress]
  public var cc: [EmailAddress]? = nil
  public var bcc: [EmailAddress]? = nil
  public var subject: String
  public var text: String?
  public var html: String?
  public var testMode: Bool? = nil
  public var tracking: Tracking? = nil
  public var trackingClicks: TrackingClicks? = nil
  public var trackingOpens: TrackingOpens? = nil
  public var domain: String
  public var headers: [(String, String)] = []
}
