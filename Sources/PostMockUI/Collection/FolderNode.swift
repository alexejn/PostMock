//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct FolderNode: View { 
  let item: CollectionItems.Item

  @EnvironmentObject var model: PostMock
  @EnvironmentObject var collection: CollectionsViewModel

  @State private var badge: Int = 0

  var header: some View {
    FolderLabel(name: item.name, 
                badge: badge)
  }

  var body: some View {
    if let items = item.item {
      CollapsableView(id: item.id) {
        header
          .onAppear {
            Task { @MainActor in
              badge = await collection.badges(for: item)
            }
          }
      } content: {
        ForEach(items) { itm in
          if let request = itm.request {
            RequestNode(request: request, item: itm)
          } else {
            FolderNode(item: itm)
          }
        }
      }
    } else {
      header
        .padding(.leading, 30)
    }
  }
}

private struct FolderLabel: View {
  let name: String
  var badge: Int = 0

  var body: some View {
    HStack {
      Image(systemName: "folder")
      Text(name)
        .font(.title2.weight(.medium))
      Spacer()

      if badge != 0 {
        Text("\(badge)")
          .foregroundColor(.gray.opacity(0.5))
      }
    }
    .padding(.leading, 20)
  }
}

struct FolderNode_Previews: PreviewProvider {
  static let req = CollectionItems.Item.createCollection

  static var previews: some View {
    FolderNode(item: req)
      .padding()
      .environmentObject(PostMock.shared)
      .environmentObject(CollectionsViewModel(.sample))
  }
}
