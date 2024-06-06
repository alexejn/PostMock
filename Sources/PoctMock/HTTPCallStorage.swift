//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

actor HTTPCallStorage {
  private(set) var info: [CallID: HTTPCall] = [:]

  private init() {}

  static var shared = HTTPCallStorage()

  func duration(for callID: CallID) -> TimeInterval? {
    info[callID]?.duration
  }

  func set(_ inf: HTTPCall) {
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

extension HTTPCallStorage {
  func calls(by template: RequestTemplate) -> [HTTPCall] {

    info.values.filter { info in
      template.isMathing(request: info.request)
    }
  }
}
