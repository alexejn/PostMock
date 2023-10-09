//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct RequestDetailView: View {

  @StateObject var model: RequestDetailViewModel

  init(item: CollectionItems.Item,
       request: CollectionItems.Request) {
    self._model = StateObject(wrappedValue: .init(item: item,
                                                  request: request))
  }

  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        HStack {
          RequestLabel(name: model.item.name,
                       method: model.request.method,
                       url: model.request.url.raw)
          Spacer()
          Button(action: {
            model.openLink()
          }) {
            Image(systemName: "link")
          }
        }
        HStack(spacing: 10) {
          Text("ID")
            .font(.footnote.weight(.bold))
            .frame(width: 55, alignment: .trailing)
          Text(model.item.uid)
            .font(.caption)
          Spacer()

          Button(action: {
            model.copyToClipboard()
          }) {
            Image(systemName: "doc.on.doc")
          }
        }
        Divider()
      }
      .padding(.leading, 4)
      .padding([.top, .bottom, .trailing])
      .background(Color.white)
      ScrollView {
        ForEach(model.calls, id: \.callID) { call in
          NavigationLink {
            CallDetailView(call: call)
          } label: {
            CallItem(call: call)
          }
        }
      }
    }
  }
}

struct RequestDetailView_Previews: PreviewProvider {
  static let req = CollectionItems.Item.authorize

  static var previews: some View {
    RequestDetailView(item: req, request: req.request!)
  }
}
