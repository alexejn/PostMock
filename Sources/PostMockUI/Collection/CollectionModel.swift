//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import SwiftUI

final class CollectionsViewModel: ObservableObject {

  var collection: Workspace.Collection
  @Published var isLoading: Bool = true
  @Published var error: String?
  @Published var selectedItem: SelectedItem?
  @Published var collectionItems: CollectionItems?
  private let storage = Storage(logger: .postmock)


  enum SelectedItem: Identifiable {
    case request(item: CollectionItems.Item, request: CollectionItems.Request)
    case response(item: CollectionItems.Item, response: CollectionItems.Response)

    var id: String {
      switch self {
      case let .request(item, _): 
        return "request.\(item.id)"
      case let .response(_, response):
        return "response.\(response.id)"
      }
    }
  }

  init(_ collection: Workspace.Collection) {
    self.collection = collection
    restoreOrLoad()
  }

  private func restoreOrLoad() {
    Task { @MainActor in
      self.collectionItems = await storage.restore(from: .collection(collectionUID: collection.uid))
      guard self.collectionItems == nil else { return }
      await load()
    }
  }

  func badges(for item: CollectionItems.Item) async -> Int {
    
    var count: Int = 0
    if let items = item.item {
      for item in items {
        let cnt = await badges(for: item)
        count += cnt
      }
      return count
    } else if let pattern = item.pattern {

      count = await URLRequestCallInfos.shared.calls(by: pattern).count
    }
    return count
  }

  @MainActor
  func load() async {
    storage.remove(file: .collection(collectionUID: collection.uid))
    self.collectionItems = nil
    do {
      isLoading = true
      self.collectionItems = try await PostmanAPI.collectionItems(collectionID: collection.id)
      isLoading = false
      try? await storage.store(data: self.collectionItems!, to: .collection(collectionUID: collection.uid))
    } catch {
      isLoading = false
      self.error = error.localizedDescription
    }
  }

  func loadNewCollection(collection: Workspace.Collection) {
    guard self.collection != collection else { return }
    self.collection = collection
    self.collectionItems = nil
    restoreOrLoad()
  }
}
