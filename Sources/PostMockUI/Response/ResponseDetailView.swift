//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct ResponseDetailView: View {
  var item: CollectionItems.Item
  var response: CollectionItems.Response

  @EnvironmentObject var model: CollectionsViewModel
  @EnvironmentObject var mocks: MockStorage
  @State private var fullInfo: Bool = false

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
          if let template = item.requestTemplate {
            if usedForMock {
              Button("UnMock") {
                withAnimation {
                  mocks.removeMock(for: template)
                }
              }
              .foregroundColor(.red)
            } else {
              Button("Mock") {
                withAnimation {
                  let mock = Mock(requestTemplate: template,
                                  responseID: response.uid,
                                  placeholders: [:])
                  mocks.set(mock: mock)
                }
              }
              .foregroundColor(.blue)
            }
          }
        }
        .buttonStyle(.plain)

        Divider()
        HStack(spacing: 10) {
          Text("ID")
            .font(.footnote.weight(.bold))
          Text(response.uid)
            .font(.caption)
          Spacer()

          Button(action: {
            UIPasteboard.general.string = response.uid
          }) {
            Image(systemName: "doc.on.doc")
          }
        }

        if let template = item.requestTemplate, usedForMock {
          Divider()
          if fullInfo {
            VStack(alignment: .leading) {
              Text("Mocked if request match template")
                .fontWeight(.light)
              Text(template.actualDescription)
                .fontWeight(.medium)
                .font(.callout)
                .lineLimit(0)
                .multilineTextAlignment(.leading)
              Spacer()
                .frame(height: 12)
              Text("or has header **\(PostMock.Headers.xPostmanRequestId)** equals to:")
                .fontWeight(.light)
              Text(item.uid)
                .fontWeight(.thin)
                .font(.footnote)
            }
            .font(.footnote)
          } else {
            Button(action: {
              withAnimation {
                fullInfo.toggle()
              }
            }) {
              Text(template.description)
                .foregroundColor(.blue)
                .font(.callout)
            }
          }
        }
        Divider()
      }
      .animation(.easeInOut, value: fullInfo)
      .padding([.top, .horizontal])
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
  static let mocks = MockStorage()

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
