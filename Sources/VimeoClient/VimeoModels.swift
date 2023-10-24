import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct VimeoVideo: Decodable, Equatable {
  public let created: Date
  public let description: String?
  public let name: String
  public let privacy: Privacy
  public let type: VideoType

  public typealias ID = Tagged<Self, Int>

  @MemberwiseInit(.public)
  public struct Privacy: Decodable, Equatable {
    public let view: View?

    public enum View: String, Decodable {
      case anybody
      case disable
    }
  }

  public enum VideoType: String, Decodable {
    case live
    case video
  }

  enum CodingKeys: String, CodingKey {
    case created = "created_time"
    case description
    case name
    case privacy
    case type
  }
}
