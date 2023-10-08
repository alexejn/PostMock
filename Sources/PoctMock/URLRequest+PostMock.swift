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

    setValue(mockResponseID, forHTTPHeaderField: PostMock.Headers.xMockResponseId)
    setValue(PostMock.shared.config.apiKey, forHTTPHeaderField: PostMock.Headers.xApiKey)
    setValue(host, forHTTPHeaderField: PostMock.Headers.xMockedHost)

    let urlWithMockHost = requestUrl.absoluteString.replacingOccurrences(of: host,
                                                                         with: mockServer.host)
    self.url = URL(string: urlWithMockHost)!
    return true
  }

  @discardableResult
  public mutating func setCallId() -> String {
    let uuid = UUID().uuidString
    setValue(uuid, forHTTPHeaderField: PostMock.Headers.xCallId)
    return uuid
  }

  public var callID: String? {
    value(forHTTPHeaderField: PostMock.Headers.xCallId)
  }
}
