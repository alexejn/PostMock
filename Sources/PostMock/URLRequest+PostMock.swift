//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

extension URLRequest {

  @discardableResult
  mutating func mockIfNeed() -> Bool {
    guard PostMock.shared.mockIsEnabled,
          let mockServer = PostMock.shared.mockServer,
          !PostMock.shared.config.apiKey.isEmpty,
          let requestUrl = url,
          let host = requestUrl.host else { return false }

    guard let mock = MockStorage.shared.mock(for: self) else { return false }

    setValue(mock.responseID, forHTTPHeaderField: PostMock.Headers.xMockResponseId)
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
