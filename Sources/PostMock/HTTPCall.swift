//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

typealias CallID = UUID

struct HTTPCall: CustomStringConvertible {
  public let callID: CallID
  public let request: URLRequest
  public var redirectRequest: URLRequest?
  public var response: URLResponse? {
    didSet {
      if let response = response as? HTTPURLResponse {
        self.status = .init(code: response.statusCode)
        self.responseHeader = response.allHeaderFields as? [String: String]
      }
    }
  }
  public var data: Data?
  var status: URLResponse.Status?
  public var responseHeader: [String: String]?

  public var error: Error?
  public var decodeError: Error?
  public var start: TimeInterval = CFAbsoluteTimeGetCurrent()
  public var end: TimeInterval?

  public var method: String { request.httpMethod ?? "" }
  public var path: String { request.url?.path ?? "" }
  public var query: String { request.url?.query ?? "" }
  public var pathAndQuery: String { path + (query.isEmpty ? "" : "?\(query)") }
  public var host: String { request.url?.host ?? "" }

  public var duration: TimeInterval? {
    guard let end else { return nil }
    return end - start
  }

  public var description: String {
    method + " " + path
  }
}


