//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

public extension PostMock {
  struct Request {

    public let pattern: PostmanRequestPattern

    public var responceID: String = ""

    public init(_ method: String, host placeholder: String = "{{host}}", path: String, requestUID: String = "") {
      self.init(pattern: .init(method: method, hostPlaceholder: placeholder, path: path, requestUID: requestUID))
    }

    public init(pattern: PostmanRequestPattern) {
      self.pattern = pattern
    }

    public init(requestID: String) {
      self.init(pattern: .init(method: "", hostPlaceholder: "", path: "", requestUID: requestID))
    }

    public mutating func mock(with responceID: MockResponseID) {
      self.responceID = responceID
      PostmanRequestsMocks.shared
        .setMock(pattern: pattern, mockResponseID: responceID)
    }
  }
}
