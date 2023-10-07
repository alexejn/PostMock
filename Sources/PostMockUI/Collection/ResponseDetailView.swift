import SwiftUI
struct ResponseDetailView: View {
  var item: CollectionItems.Item
  var response: CollectionItems.Response

  @EnvironmentObject var model: CollectionsViewModel
  @EnvironmentObject var mocks: PostmanRequestsMocks

  private var usedForMock: Bool { mocks.isMocked(requestUID: item.uid,
                                                 withResponseID: response.uid) }
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        HStack {
          VStack(alignment: .leading) {
            ResponseLabel(name: response.name)
            Text("\(response.code) \(response.status)")
              .bold()
          }
          Spacer()
          if let pattern = item.pattern {
            if usedForMock {
              Button("UnMock") {
                withAnimation {
                  mocks.removeMock(for: pattern)
                }
              }
              .foregroundColor(.red)
            } else {
              Button("Mock") {
                withAnimation {
                  mocks.setMock(pattern: pattern, mockResponseID: response.uid)
                }
              }
              .foregroundColor(.blue)

            }
          }
        }
        .buttonStyle(.plain)
        Divider()
        if let pattern = item.pattern, usedForMock {
          Text(pattern.description)
            .foregroundColor(.blue)
          Divider()
        }
      }
      .padding([.top, .horizontal])
      .background(Color.white)
      .environment(\.isMocked, usedForMock)
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 5) {

          Text(response.body)
            .font(.callout.weight(.light))
        }
        .padding()
      }
    }
  }
}

struct ResponseDetailView_Previews: PreviewProvider {
  static let req = CollectionItems.Item.authorize

  static let model = CollectionsViewModel(.sample)
  static let mocks = PostmanRequestsMocks()

  static var previews: some View {
    Text("Demo")
      .sheet(isPresented: .constant(true)) {
        ResponseDetailView(item: req, response: req.response!.first!)
          .environmentObject(model)
          .environmentObject(mocks)
          .environmentObject(PostMock.shared)
      }
  }
}
