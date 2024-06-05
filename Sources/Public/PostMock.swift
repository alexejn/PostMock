//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import SwiftUI
import os

extension Logger {
  static var postmock = Logger(subsystem: "main", category: "postmock")
}

public final class PostMock: ObservableObject {

  public var isEnabled: Bool = false {
    didSet {
      if isEnabled {
        URLProtocol.registerClass(PostMockURLProtocol.self)
      } else {
        URLProtocol.unregisterClass(PostMockURLProtocol.self)
      }
    }
  }

  @Published var config: Config = .empty {
    didSet {
      configured = true
      configID = config.id
    }
  }

  @Published var configured: Bool = false

  @UserDefault(key: "postmock.mockServer", defaultValue: nil) 
  public var mockServer: MockServer?

  public private(set) var environment: PostMockEnvironment = .shared

  private let storage = Storage(logger: .postmock)

  var storedConfigs: [Config] = [] {
    didSet {
      guard storedConfigs != oldValue else { return }
      Task {
        try? await storage.store(data: storedConfigs, to: .configurateion)
      }
    }
  }

  @AppStorage("postmock.mockIsEnabled") public var mockIsEnabled: Bool = false {
    didSet { objectWillChange.send() }
  }

  @AppStorage("postmock.configID") private var configID: String? {
    didSet { objectWillChange.send() }
  }

  private init() { 
    restoreAndSetDefaultConfigIfCan()
  }

  private func restoreAndSetDefaultConfigIfCan() {
    Task {
      if let configs: [PostMock.Config] = await storage.restore(from: .configurateion)  {
        self.storedConfigs = configs
      }

      if let config: PostMock.Config = storedConfigs.first(where: { $0.id == configID }) {
        self.config = config
      }
    }
  }

  public static var shared = PostMock()

  public func configurate(with config: Config) {
    self.config = config
  }

  public func clearAllMocks() {
    MockStorage.shared.clearAll()
  }
}


public enum PostMockError: Error, CustomStringConvertible {
  case NotConfigured

  public var description: String {
    switch self {
    case .NotConfigured: return "Not configured"
    }
  }
}
