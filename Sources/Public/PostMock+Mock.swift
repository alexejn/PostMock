//
//  File.swift
//  
//
//  Created by Alexey Nenastev on 8.10.23..
//

import Foundation

public extension PostMock {
  struct Mock {

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

    public mutating func with(_ responceID: MockResponseID) {
      self.responceID = responceID
      PostmanRequestsMocks.shared
        .setMock(pattern: pattern, mockResponseID: responceID)
    }
  }
}
