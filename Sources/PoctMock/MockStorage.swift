//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

extension UserDefaults {
  static let mocks = UserDefaults(suiteName: "PostmanMocks")!
}

final class MockStorage: ObservableObject {

  private var mocks: [RequestTemplate: Mock] {
    didSet {
      UserDefaults.mocks.set(codable: mocks, forKey: "postmanMocks")
    }
  }

  var mocked: [RequestTemplate] { Array(mocks.keys) }

  init() {
    mocks = UserDefaults.mocks.decode(forKey: "postmanMocks") ?? [:]
  }

  static var shared = MockStorage()

  func set(mock: Mock) {
    mocks[mock.requestTemplate] = mock
    objectWillChange.send()
  }

  func isMocked(requestUID: String) -> Bool {
    mock(for: requestUID) != nil
  }

  func isMocked(requestUID: String, withResponseID: String) -> Bool {
    mock(for: requestUID)?.responseID == withResponseID
  }

  func removeMock(for pattern: RequestTemplate) {
    mocks.removeValue(forKey: pattern)
    objectWillChange.send()
  }

  func clearAll() {
    mocks = [:]
    objectWillChange.send()
  }

  func mock(for requestUID: String) -> Mock? {
    if let template = mocks.keys.first(where: { $0.requestUID == requestUID }) {
      return mocks[template]
    } else {
      return nil
    }
  }

  func mock(for urlRequest: URLRequest) -> Mock? {
    mocks.values.first(where: { $0.isMathing(request: urlRequest) })
  }
}
