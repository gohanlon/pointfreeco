import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct EpisodeProgress: Codable, Equatable, Identifiable {
  public let createdAt: Date
  public let episodeSequence: Episode.Sequence
  public let id: Tagged<Self, UUID>
  public let isFinished: Bool
  public let percent: Int
  public let userID: User.ID
  public let updatedAt: Date?
}
