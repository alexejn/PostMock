import Foundation
import HTTPTypes

extension UserDefaults {
  public static let mocks = UserDefaults(suiteName: "PostmanMocks")!
}

public typealias MockResponseID = String

public final class PostmanRequestsMocks: ObservableObject {

  private var mocks: [PostmanRequestPattern: MockResponseID] {
    didSet {
      UserDefaults.mocks.set(codable: mocks, forKey: "postmanMocks")
    }
  }

  public var mocked: [PostmanRequestPattern] { Array(mocks.keys) }

  init() {
    mocks = UserDefaults.mocks.decode(forKey: "postmanMocks") ?? [:]
  }

  public static var shared = PostmanRequestsMocks()

  public func setMock(pattern: PostmanRequestPattern, mockResponseID: MockResponseID) {
    mocks[pattern] = mockResponseID
    objectWillChange.send()
  }

  public func isMocked(requestUID: String) -> Bool {
    mockResponseID(requestUID: requestUID) != nil
  }

  public func isMocked(requestUID: String, withResponseID: String) -> Bool {
    mockResponseID(requestUID: requestUID) == withResponseID
  }

  public func removeMock(for pattern: PostmanRequestPattern) {
    mocks.removeValue(forKey: pattern)
    objectWillChange.send()
  }

  public func clearAll() {
    mocks = [:]
    objectWillChange.send()
  }

  func mockResponseID(requestUID: String) -> MockResponseID? {
    if let pattern = mocks.keys.first(where: { $0.requestUID == requestUID }) {
      return mocks[pattern]
    } else {
      return nil
    }
  }

  func mockResponseID(for urlRequest: URLRequest) -> MockResponseID? {
    if let matchedMockKey = mocks.keys.first(where: { $0.match(request: urlRequest) }) {
      return mocks[matchedMockKey]
    } else {
      return nil
    }
  }
}

/// Структура позволяет мокать программно
public struct Mock {

  public let pattern: PostmanRequestPattern

  public var responceID: String = ""

  public init(_ method: HTTPRequest.Method, host placeholder: String = "{{host}}", path: String, requestUID: String = "") {
    self.init(pattern: .init(method: method.rawValue, hostPlaceholder: placeholder, path: path, requestUID: requestUID))
  }

  public init(pattern: PostmanRequestPattern) {
    self.pattern = pattern
  }

  public init(requestID: String) {
    self.init(pattern: .init(method: "", hostPlaceholder: "", path: "", requestUID: requestID))
  }

  public mutating func with(_ responceID: MockResponseID) {
    self.responceID = responceID
    PostmanRequestsMocks.shared
      .setMock(pattern: pattern, mockResponseID: responceID)
  }
}
