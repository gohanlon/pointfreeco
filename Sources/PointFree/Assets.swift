import Dependencies
import MemberwiseInit

@MemberwiseInit(.public)
public struct Assets {
  public var brandonImgSrc: String = "https://d3rccdn33rt8ze.cloudfront.net/about-us/brando.jpg"
  public var stephenImgSrc: String = "https://d3rccdn33rt8ze.cloudfront.net/about-us/stephen.jpg"
  public var emailHeaderImgSrc: String =
    "https://d3rccdn33rt8ze.cloudfront.net/email-assets/pf-email-header.png"
  public var pointersEmailHeaderImgSrc: String =
    "https://d3rccdn33rt8ze.cloudfront.net/email-assets/pf-pointers-header.jpg"
}

extension Assets: DependencyKey {
  public static let liveValue = Assets()
  public static let testValue = Assets(
    brandonImgSrc: "",
    stephenImgSrc: "",
    emailHeaderImgSrc: "",
    pointersEmailHeaderImgSrc: ""
  )
}

extension DependencyValues {
  public var assets: Assets {
    get { self[Assets.self] }
    set { self[Assets.self] = newValue }
  }
}
