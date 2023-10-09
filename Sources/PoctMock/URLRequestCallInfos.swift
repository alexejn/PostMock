//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

typealias CallID = UUID

struct HTTPCallInfo: CustomStringConvertible {
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
  public var host: String { request.url?.host ?? "" }

  public var duration: TimeInterval? {
    guard let end else { return nil }
    return end - start
  }

  public var description: String {
    method + " " + path
  }
}

actor URLRequestCallInfos {
  private(set) var info: [CallID: HTTPCallInfo] = [:]

  private init() {}

  static var shared = URLRequestCallInfos()

  func duration(for callID: CallID) -> TimeInterval? {
    info[callID]?.duration
  }

  func set(_ inf: HTTPCallInfo) {
    info[inf.callID] = inf
  }

  func startWith(_ request: URLRequest, callID: CallID) {
    info[callID] = .init(callID: callID, request: request)
  }

  func endWith(_ error: Error, callID: UUID) {
    info[callID]?.end = CFAbsoluteTimeGetCurrent()
    info[callID]?.error = error
  }

  func endWith(response: HTTPURLResponse, data: Data, callID: UUID) {
    info[callID]?.end = CFAbsoluteTimeGetCurrent()
    info[callID]?.response = response
    info[callID]?.data = data
  }

  func dateDecodeError(_ error: Error, callID: UUID) {
    info[callID]?.decodeError = error
  }

  func dateDecodeError(_ error: Error, responce: URLResponse) {
    guard let inf = info.values.first(where: { $0.response == responce }) else { return }
    info[inf.callID]?.decodeError = error
  }
  
  public func clear() {
    info = [:]
  }
}
