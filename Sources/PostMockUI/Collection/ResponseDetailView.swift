//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

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


        if let pattern = item.pattern, usedForMock {
          Divider()
          VStack(alignment: .leading) {
            Text("Mocked if request match template")
              .fontWeight(.light)
            Text(pattern.description)
              .foregroundColor(.blue)
              .font(.callout)
            Spacer()
              .frame(height: 5)
            Text("or has header \(PostMock.Headers.xPostmanRequestId) equal")
              .fontWeight(.light)
            Text(item.uid)
              .fontWeight(.thin)
              .font(.footnote)
          }
            .font(.footnote)
        }
        Divider()
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
