//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import SwiftUI
import os

extension Logger {
  static var postmock = Logger(subsystem: "main", category: "postmock")
}

extension UserDefaults {
  static let cache = UserDefaults(suiteName: "postmock.cache")!
}

public final class PostMock: ObservableObject {

  enum UDKey: String {
    case isEnabled = "postmock.mockIsEnabled"
    case defaultMockServer = "postmock.defaultMockServer"
  }

  var isEnabled: Bool = false
  @Published var config: PostMockConfig = .test
  @Published var mockServer: MockServer?  {
    didSet {
      UserDefaults.cache.set(codable: mockServer, forKey: UDKey.defaultMockServer.rawValue)
    }
  }

  @Published var collection: Workspace.Collection? {
    didSet {
      if let mockServer = mockServer, collectionMockServers.contains(mockServer) {
        return
      }
      mockServer = defaultMockServer ?? collectionMockServers.first
    }
  }


  @Published var cacheWorkspace: Bool = false

  @Published public var mockIsEnabled: Bool = false {
    didSet {
      UserDefaults.cache.set(mockIsEnabled, forKey: UDKey.isEnabled.rawValue)
    }
  }

  @Published var isLoading: Bool = false
  @Published var isLoaded: Bool = false
  @Published var error: String?
  @Published var workspace: Workspace?

  var collectionMockServers: [MockServer] {
    guard let collection = collection else { return mockServers }
    return mockServers.filter { $0.collection == collection.uid }
  }

  private(set) var mockServers: [MockServer] = []

  private(set) var collections: [Workspace.Collection] = [] {
    didSet {
      if let collection = collection, collections.contains(collection) {
        return
      }
      collection = defaultCollection ?? collections.first
    }
  }

  public typealias PlaceholderValueProvider = () -> String

  public var placeholderValues: [String: PlaceholderValueProvider] = [:]

  func value(forPlaceholder: String) -> String? {
    placeholderValues[forPlaceholder]?()
  }

  var defaultCollection: Workspace.Collection? {
    collections.first(where: {$0.id == config.defaultCollectionID || $0.uid == config.defaultCollectionID })
  }

  var defaultMockServer: MockServer? {
    collectionMockServers.first(where: {$0.id == config.defaultMockServerID})
  }


  init() {
    self.mockIsEnabled = UserDefaults.standard.bool(forKey: UDKey.isEnabled.rawValue)
    self.mockServer = UserDefaults.standard.decode( forKey: UDKey.defaultMockServer.rawValue)
  }

  @MainActor
  func load() async {
    defer {
      isLoading = false
    }
    do {
      guard config.workspaceID.isEmpty == false else { throw PostMockError.NotConfigured }
      isLoading = true
      let workspace = try await PostmanAPI.workspace(worspaceID: config.workspaceID)
      self.mockServers = try await PostmanAPI.mocks(workspaceID: config.workspaceID)
      self.collections = workspace.collections ?? []
      self.workspace = workspace
      isLoaded = true
    } catch {
      self.error = "\(error)"
      Logger.postmock.error("Load failed \(error)")
    }
  }

  public static var shared = PostMock()

  func reload() {
    Task { @MainActor in
      workspace = nil
      await load()
    }
  }

  public func configurate(with config: PostMockConfig) {
    self.config = config
  }

  public func enable() {
    guard isEnabled == false else { return }
    URLProtocol.registerClass(PostMockURLProtocol.self)
    self.isEnabled = true
  }

  public func disabled() {
    guard isEnabled else { return }
    URLProtocol.unregisterClass(PostMockURLProtocol.self)
    self.isLoading = false
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
