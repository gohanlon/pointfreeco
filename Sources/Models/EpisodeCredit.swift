import MemberwiseInit

@MemberwiseInit(.public)
public struct EpisodeCredit: Decodable, Equatable {
  public var episodeSequence: Episode.Sequence
  public var userId: User.ID
}
