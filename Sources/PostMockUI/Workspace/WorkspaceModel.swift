//
// Created by Alexey Nenastyev on 11.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import os
import SwiftUI

final class WorkspaceModel: ObservableObject {

  private let workspaceID: String
  private let cache = UserDefaults(suiteName: "postmock.cache")!
  private let storage = Storage(logger: .postmock)

  @Published var isWorkspaceLoading = false
  @Published var loadError: String?

  @Published var workspace: Workspace? {
    didSet {
      currentCollectionUID = collection?.uid ?? collections.first?.uid
    }
  }
  var collections: [Workspace.Collection] { workspace?.collections ?? [] }

  @Published var servers: [MockServer] = [] {
    didSet {
      currentMockServerID = mockServer?.id ?? servers.first?.id
    }
  }

  var collectionMockServers: [MockServer] {
    guard let currentCollectionUID = currentCollectionUID else { return servers }
    return servers.filter { $0.collection == currentCollectionUID }
  }

  @Published var currentCollectionUID: String? {
    didSet {
      cache.set(currentCollectionUID, forKey: udKeyCurrentCollection)
    }
  }
  var collection: Workspace.Collection? { collections.first(where: {$0.uid == currentCollectionUID }) }


  @Published var currentMockServerID: String? {
    didSet {
      cache.set(currentMockServerID, forKey: udKeyCurrentMockServer)
      PostMock.shared.mockServer = mockServer
    }
  }
  private var mockServer: MockServer? { collectionMockServers.first(where: { $0.id == currentMockServerID })}

  private var udKeyCurrentCollection: String { "\(workspaceID).collcetionID" }
  private var udKeyCurrentMockServer: String { "\(currentCollectionUID ?? "").mockServerID" }

  init(workspaceID: String) {
    self.workspaceID = workspaceID
    self.currentCollectionUID = cache.string(forKey: udKeyCurrentCollection)
    self.currentMockServerID = cache.string(forKey: udKeyCurrentMockServer)
    restoreOrLoad()
  }

  private func restoreOrLoad() {
    Task { @MainActor in
      self.workspace = await storage.restore(from: .workspace(workspaceID: workspaceID))
      self.servers = await storage.restore(from: .mockServers(workspaceID: workspaceID)) ?? []

      guard self.workspace == nil else { return }
      await load()
    }
  }

  private func storeState() async {
    guard let workspace = workspace else { return }
    do {
      try await storage.store(data: workspace, to: .workspace(workspaceID: workspaceID))
      try await storage.store(data: self.servers, to: .mockServers(workspaceID: workspaceID))
    } catch {
      Logger.postmock.error("Store state error \(error)")
    }
  }

  private func clearStored() {
    storage.remove(file: .workspace(workspaceID: workspaceID))
    storage.remove(file: .mockServers(workspaceID: workspaceID))
    if let currentCollectionUID = currentCollectionUID {
      storage.remove(file: .collection(collectionUID: currentCollectionUID))
    }
  }

  @MainActor
  private func load() async {
    clearStored()
    do {
      isWorkspaceLoading = true
      self.workspace = try await PostmanAPI.workspace(worspaceID: workspaceID)
      self.servers = try await PostmanAPI.mocks(workspaceID: workspaceID)
      isWorkspaceLoading = false
      await storeState()
    } catch {
      isWorkspaceLoading = false
      self.loadError = "\(error)"
      Logger.postmock.error("Load failed \(error)")
    }
  }

  func reload() {
    Task { @MainActor in
      await load()
    }
  }
}
