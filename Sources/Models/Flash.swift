import MemberwiseInit

@MemberwiseInit(.public)
public struct Flash: Codable, Equatable {
  public enum Priority: String, Codable {
    case error
    case notice
    case warning
  }

  @Init(label: "_") public let priority: Priority
  @Init(label: "_") public let message: String
}
