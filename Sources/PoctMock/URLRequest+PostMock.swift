import HTTPTypes
import HTTPTypesFoundation
import Foundation

extension URLRequest {

  @discardableResult
  mutating func mockIfNeed() -> Bool {
    guard PostMock.shared.mockIsEnabled,
          let mockServer = PostMock.shared.mockServer,
          !PostMock.shared.config.apiKey.isEmpty,
          let requestUrl = url,
          let host = requestUrl.host else { return false }

    guard let mockResponseID = PostmanRequestsMocks.shared.mockResponseID(for: self) else { return false }

    allHTTPHeaderFields?[.Postman.xMockResponseId] = mockResponseID
    allHTTPHeaderFields?[.Postman.xApiKey] = PostMock.shared.config.apiKey
    allHTTPHeaderFields?[.PostMock.xMockedHost] = host

    let urlWithMockHost = requestUrl.absoluteString.replacingOccurrences(of: host,
                                                                         with: mockServer.host)
    self.url = URL(string: urlWithMockHost)!
    return true
  }

  @discardableResult
  public mutating func setCallId() -> String {
    let uuid = UUID().uuidString
    allHTTPHeaderFields?[.PostMock.xCallId] = uuid
    return uuid
  }

  public var callID: UUID? {
    guard let stringUUID = allHTTPHeaderFields?[.PostMock.xCallId] else { return nil }
    return UUID(uuidString: stringUUID)
  }
}

extension HTTPRequest {
  @discardableResult
  public mutating func setCallId() -> String {
    let uuid = UUID().uuidString
    headerFields[.PostMock.xCallId] = uuid
    return uuid
  }
}
