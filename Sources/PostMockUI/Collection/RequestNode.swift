import SwiftUI

struct RequestNode: View {
  let request: CollectionItems.Request
  let item: CollectionItems.Item
  @State var badge: Int = 0

  @EnvironmentObject var model: CollectionsViewModel
  @EnvironmentObject var mocks: PostmanRequestsMocks

  var header: some View {
    RequestLabel(name: item.name,
                 method: request.method,
                 url: request.url.raw,
                 badge: badge)
    .padding(.leading, -12)
    .lineLimit(3)
    .onTapGesture {
      model.selectedItem = .request(item: item, request: request)
    }
    .onAppear {
      Task { @MainActor in
        badge = await model.badges(for: item)
      }
    }
  }

  private func responseView(response: CollectionItems.Response) -> some View {
    Button {
      model.selectedItem = .response(item: item, response: response)
    } label: {
      ResponseLabel(name: response.name)
        .environment(\.isMocked, mocks.isMocked(requestUID: item.uid,
                                                withResponseID: response.uid))
    }.offset(x: 60)
  }

  var body: some View {
    if let responses = item.response, !responses.isEmpty {
      CollapsableView(id: item.id) {
        header
      } content: {
        ForEach(responses, content: responseView)
      }
      .environment(\.isMocked, mocks.isMocked(requestUID: item.uid))
    } else {
      header
        .offset(x: 30)
    }
  }
}

struct RequestNode_Previews: PreviewProvider {
  static let req = CollectionItems.Item.authorize
  static let mocks = PostmanRequestsMocks()
  static let collectionModel = CollectionsViewModel(.sample)
  
  static var previews: some View {
    RequestNode(request: req.request!, item: req)
      .padding()
      .environmentObject(collectionModel)
      .environmentObject(mocks)
      .environmentObject(PostMock.shared)
  }
}
