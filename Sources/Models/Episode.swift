import Dependencies
import Foundation
import MemberwiseInit
import Tagged
import TaggedTime

@MemberwiseInit(.public)
public struct Episode: Equatable, Identifiable {
  public var alternateSlug: String? = nil
  public var blurb: String
  public var codeSampleDirectory: String? = nil
  public var exercises: [Exercise] = []
  public var format: Format = .prerecorded
  @Init(.public, label: "fullVideo") public private(set) var _fullVideo: Video? = nil
  public var id: Tagged<Self, Int>
  @Init(label: "image") public var _image: String? = nil
  public var length: Seconds<Int>
  public var permission: Permission
  public var publishedAt: Date
  public var questions: [Question] = []
  public var references: [Reference] = []
  public var sequence: Sequence
  public var subtitle: String? = nil
  public var title: String
  public var trailerVideo: Video
  @Init(label: "transcriptBlocks") public var _transcriptBlocks: [TranscriptBlock]? = nil

  public var image: String {
    get {
      self._image
        ?? .init(
          format: "https://d3rccdn33rt8ze.cloudfront.net/episodes/%04d.jpeg", sequence.rawValue
        )
    }
    set {
      self._image = newValue
    }
  }

  @MemberwiseInit(.public)
  public struct Question: Equatable {
    public var answer: String
    public var question: String
    public var timestamp: Int
  }

  public var fullTitle: String {
    self.subtitle.map { "\(self.title): \($0)" } ?? self.title
  }

  public var slug: String {
    return "ep\(self.sequence)-" + (self.alternateSlug ?? "\(Models.slug(for: self.fullTitle))")
  }

  public func isSubscriberOnly(currentDate: Date, emergencyMode: Bool) -> Bool {
    guard !emergencyMode else { return false }

    switch self.permission {
    case .free:
      return false
    case let .freeDuring(dateRange):
      return !dateRange.contains(currentDate)
    case .subscriberOnly:
      return true
    }
  }

  public var freeSince: Date? {
    switch self.permission {
    case .free:
      return self.publishedAt
    case let .freeDuring(dateRange):
      return dateRange.lowerBound
    case .subscriberOnly:
      return nil
    }
  }

  public typealias Sequence = Tagged<(sequence: (), Self), Int>

  @MemberwiseInit(.public)
  public struct Collection: Equatable {
    public var blurb: String
    public var sections: [Section]
    public var title: String

    public init(
      section: Section
    ) {
      self.blurb = section.blurb
      self.sections = [section]
      self.title = section.title
    }

    public var length: Seconds<Int> {
      self.sections
        .flatMap { $0.coreLessons.map(\.episode.length) }
        .reduce(into: 0, +=)
    }

    public var slug: Slug {
      .init(rawValue: Models.slug(for: self.title))
    }

    @MemberwiseInit(.public)
    public struct Section: Equatable {
      public var alternateSlug: String? = nil
      public var blurb: String
      public var coreLessons: [Lesson]
      public var isFinished: Bool = true
      public var isHidden: Bool = false
      public var related: [Related]
      public var title: String
      public var whereToGoFromHere: String?

      public var length: Seconds<Int> {
        self.coreLessons
          .map(\.episode.length)
          .reduce(into: 0, +=)
      }

      public var slug: Slug {
        self.alternateSlug.map(Slug.init(rawValue:)) ?? Slug(rawValue: Models.slug(for: self.title))
      }

      @MemberwiseInit(.public)
      public struct Lesson: Equatable {
        public var episode: Episode
      }

      @MemberwiseInit(.public)
      public struct Related: Equatable {
        public var blurb: String
        public var content: Content

        public enum Content: Equatable {
          case episodes(@autoclosure () -> [Episode])
          case collections(@autoclosure () -> [Collection])
          case section(@autoclosure () -> Collection, index: Int)

          public static func episode(_ episode: @escaping @autoclosure () -> Episode) -> Content {
            .episodes([episode()])
          }

          public static func collection(_ collection: @escaping @autoclosure () -> Collection)
            -> Content
          {
            .collections([collection()])
          }

          public static func == (lhs: Content, rhs: Content) -> Bool {
            switch (lhs, rhs) {
            case let (.episodes(lhs), .episodes(rhs)):
              return lhs() == rhs()
            case let (.collections(lhs), .collections(rhs)):
              return lhs() == rhs()
            case let (.section(lhs, lhsIdx), .section(rhs, rhsIdx)):
              return lhs() == rhs() && lhsIdx == rhsIdx
            case (_, .episodes), (_, .collections), (_, .section):
              return false
            }
          }
        }
      }

      public typealias Slug = Tagged<Self, String>
    }

    public typealias Slug = Tagged<Self, String>
  }

  @MemberwiseInit(.public)
  public struct Exercise: Equatable {
    public var problem: String
    public var solution: String? = nil
  }

  public enum Format {
    case prerecorded
    case livestream
  }

  public enum Permission: Equatable {
    case free
    case freeDuring(Range<Date>)
    case subscriberOnly
  }

  @MemberwiseInit(.public)
  public struct Reference: Codable, Equatable {
    public var author: String? = nil
    public var blurb: String? = nil
    public var link: String
    public var publishedAt: Date? = nil
    public var title: String
  }

  @MemberwiseInit(.public)
  public struct TranscriptBlock: Codable, Equatable {
    public var content: String
    public var speaker: String? = nil
    public var timestamp: Int? = nil
    public var type: BlockType

    public enum BlockType: Codable, Equatable {
      case box(Box)
      case button(href: String)
      case code(lang: CodeLang)
      case image(src: String, sizing: ImageSizing)
      // TODO: rename to markdown
      case paragraph
      case question(String)
      case title
      case video(poster: String, sources: [String])

      @MemberwiseInit(.public)
      public struct Box: Codable, Equatable {
        public let title: String?
        public let backgroundColor: String
        public let borderColor: String

        public init?(name: String) {
          switch name.lowercased() {
          case "correction":
            self = .correction
          case "note":
            self = .note
          case "preamble":
            self = .preamble
          case "tip":
            self = .tip
          case "warning":
            self = .warning
          default:
            return nil
          }
        }

        public var name: String? {
          switch self {
          case .correction:
            return "correction"
          case .note:
            return "note"
          case .preamble:
            return "preamble"
          case .tip:
            return "tip"
          case .warning:
            return "warning"
          default:
            return nil
          }
        }

        public static let correction = Self(
          title: "Correction",
          backgroundColor: "ffdbdd",
          borderColor: "eb1c26"
        )
        public static let note = Self(
          title: "Note",
          backgroundColor: "f6f6f6",
          borderColor: "d8d8d8"
        )
        public static let preamble = Self(
          title: "Preamble",
          backgroundColor: "eee2ff",
          borderColor: "974dff"
        )
        public static let tip = Self(
          title: "Tip",
          backgroundColor: "dcf4e7",
          borderColor: "79f2b0"
        )
        public static let warning = Self(
          title: "⚠️ Warning",
          backgroundColor: "fcf9db",
          borderColor: "FCF18F"
        )
      }

      private enum CodingKeys: CodingKey {
        case href
        case lang
        case poster
        case question
        case sizing
        case sources
        case src
        case type
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .box(box):
          try container.encode("box", forKey: .type)
          try container.encode(box, forKey: .type)
        case let .button(href: href):
          try container.encode("button", forKey: .type)
          try container.encode(href, forKey: .href)
        case let .code(lang):
          try container.encode("code", forKey: .type)
          try container.encode(lang, forKey: .lang)
        case let .image(src, sizing):
          try container.encode("image", forKey: .type)
          try container.encode(sizing, forKey: .sizing)
          try container.encode(src, forKey: .src)
        case .paragraph:
          try container.encode("paragraph", forKey: .type)
        case let .question(question):
          try container.encode("question", forKey: .type)
          try container.encode(question, forKey: .question)
        case .title:
          try container.encode("title", forKey: .type)
        case let .video(poster, sources):
          try container.encode("video", forKey: .type)
          try container.encode(poster, forKey: .poster)
          try container.encode(sources, forKey: .sources)
        }
      }

      public init(from decoder: Decoder) throws {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: decoder.codingPath,
            debugDescription: "Unimplemented"
          )
        )
      }

      public static func image(src: String) -> BlockType {
        return .image(src: src, sizing: .fullWidth)
      }

      public enum ImageSizing: String, Codable, CaseIterable {
        case fullWidth
        case inset
      }

      public struct CodeLang: Codable, Equatable {
        public let identifier: String

        public static let diff = CodeLang(identifier: "diff")
        public static let html = CodeLang(identifier: "html")
        public static let javaScript = CodeLang(identifier: "javascript")
        public static let json = CodeLang(identifier: "json")
        public static let plainText = CodeLang(identifier: "txt")
        public static let ruby = CodeLang(identifier: "ruby")
        public static let shell = CodeLang(identifier: "bash")
        public static let sql = CodeLang(identifier: "sql")
        public static let swift = CodeLang(identifier: "swift")
      }
    }
  }

  @MemberwiseInit(.public)
  public struct Video: Codable, Equatable {
    public var bytesLength: Int
    public var downloadUrls: DownloadUrls
    public var vimeoId: Int

    public func downloadUrl(_ quality: Quality) -> String {
      switch (self.downloadUrls, quality) {
      case let (.s3(_, filename, _), .hd720), let (.s3(_, _, filename), .sd540):
        return "https://pointfreeco-episodes-processed.s3.amazonaws.com/\(filename).mp4"
      }
    }

    public var streamingSource: String {
      "https://player.vimeo.com/video/\(self.vimeoId)?pip=1"
    }

    public enum DownloadUrls: Codable, Equatable {
      case s3(hd1080: String, hd720: String, sd540: String)
    }

    public enum Quality {
      case hd720
      case sd540
    }
  }
}

func slug(for string: String) -> String {
  return
    string
    .lowercased()
    .replacingOccurrences(of: #"[\W]+"#, with: "-", options: .regularExpression)
    .replacingOccurrences(of: #"\A-|-\z"#, with: "", options: .regularExpression)
}

public func reference(
  forEpisode episode: Episode,
  additionalBlurb: String,
  episodeUrl: String
) -> Episode.Reference {
  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
      \(additionalBlurb)

      > \(episode.blurb)
      """,
    link: episodeUrl,
    publishedAt: episode.publishedAt,
    title: episode.fullTitle
  )
}

public func reference(
  forCollection collection: Episode.Collection,
  additionalBlurb: String,
  collectionUrl: String
) -> Episode.Reference {
  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
      \(additionalBlurb)

      > \(collection.blurb)
      """,
    link: collectionUrl,
    publishedAt: nil,
    title: "Collection: \(collection.title)"
  )
}

public func reference(
  forSection section: Episode.Collection.Section,
  additionalBlurb: String,
  sectionUrl: String
) -> Episode.Reference {
  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
      \(additionalBlurb)

      > \(section.blurb)
      """,
    link: sectionUrl,
    publishedAt: section.coreLessons.first?.episode.publishedAt,
    title: "Collection: \(section.title)"
  )
}

extension Episode: TestDependencyKey {
  public static let testValue: () -> [Episode] = { [.subscriberOnly, .free] }
}

extension DependencyValues {
  public var episodes: () -> [Episode] {
    get { self[Episode.self] }
    set { self[Episode.self] = newValue }
  }
}
