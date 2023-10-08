import SwiftUI

struct CollectionView: View {

  @StateObject var model: CollectionsViewModel
  @EnvironmentObject var mocks: PostmanRequestsMocks
  @EnvironmentObject var postmock: PostMock
  private var collection: Workspace.Collection

  init(collection: Workspace.Collection) {
    self.collection = collection
    self._model = StateObject(wrappedValue: CollectionsViewModel(collection))
  }

  var body: some View {
    ZStack(alignment: .center) {
      Color.clear
      if let collectionItems = model.collectionItems {
        ScrollView {
          VStack(alignment: .leading) {
            ForEach(collectionItems.item) { item in
              if let request = item.request {
                RequestNode(request: request, item: item)
              } else {
                FolderNode(item: item)
              }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
          }
        }
        .sheet(item: $model.selectedItem) { selected in
          Group {
            NavigationView {
              switch selected {
              case let .request(item, request):
                RequestDetailView(item: item, request: request)
                  .environment(\.isMocked, mocks.isMocked(requestUID: item.uid))
              case let .response(item, response):
                ResponseDetailView(item: item, response: response)
                  .environment(\.isMocked, mocks.isMocked(requestUID: item.uid,
                                                          withResponseID: response.uid))
              }
            }
          }
          .sheetDefaultSettings()
        }
      } else if model.isLoading {
        ProgressView()
      } else {
        Text("No items in collection")
      }
    }
    .environmentObject(model)
    .onChange(of: collection, perform: { value in
      Task {
        await model.loadNewCollection(collection: value)
      }
    })
  }
}

private extension View {
  func sheetDefaultSettings() -> some View {
#if os(iOS)
    if #available(iOS 16.0, *) {
      return presentationDetents([.medium, .large])
    } else { return self }
#endif

#if os(macOS)
    if #available(macOS 13.0, *) {
      return presentationDetents([.medium, .large])
    } else { return self }
#endif
  }
}

struct CollectionsView_Previews: PreviewProvider {

  static var previews: some View {
    NavigationView {
      CollectionView(collection: .init(id: "id", uid: "", name: "name"))
    }
  }
}
