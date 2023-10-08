import Foundation
import SwiftUI

final class CollectionsViewModel: ObservableObject {

  var collection: Workspace.Collection
  @Published var isLoading: Bool = true
  @Published var error: String?
  @Published var selectedItem: SelectedItem?
  @Published var collectionItems: CollectionItems? = lastLoaded
  private static var lastLoaded: CollectionItems?

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
    Task {
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
    defer {
      isLoading = false
    }
    do {
      isLoading = true
      self.collectionItems = try await PostmanAPI.collectionItems(collectionID: collection.id)
      CollectionsViewModel.lastLoaded = collectionItems
    } catch {
      self.error = error.localizedDescription
    }
  }

  @MainActor
  func loadNewCollection(collection: Workspace.Collection) async {
    guard self.collection != collection else { return }
    self.collection = collection
    self.collectionItems = nil
    await load()
  }
}
