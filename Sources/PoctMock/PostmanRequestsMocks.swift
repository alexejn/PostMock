//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

extension UserDefaults {
  static let mocks = UserDefaults(suiteName: "PostmanMocks")!
}

public typealias MockResponseID = String

final class PostmanRequestsMocks: ObservableObject {

  private var mocks: [PostmanRequestPattern: MockResponseID] {
    didSet {
      UserDefaults.mocks.set(codable: mocks, forKey: "postmanMocks")
    }
  }

  var mocked: [PostmanRequestPattern] { Array(mocks.keys) }

  init() {
    mocks = UserDefaults.mocks.decode(forKey: "postmanMocks") ?? [:]
  }

  static var shared = PostmanRequestsMocks()

  func setMock(pattern: PostmanRequestPattern, mockResponseID: MockResponseID) {
    mocks[pattern] = mockResponseID
    objectWillChange.send()
  }

  func isMocked(requestUID: String) -> Bool {
    mockResponseID(requestUID: requestUID) != nil
  }

  func isMocked(requestUID: String, withResponseID: String) -> Bool {
    mockResponseID(requestUID: requestUID) == withResponseID
  }

  func removeMock(for pattern: PostmanRequestPattern) {
    mocks.removeValue(forKey: pattern)
    objectWillChange.send()
  }

  func clearAll() {
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
