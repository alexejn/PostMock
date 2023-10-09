//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct PostmanSettingsView: View {
  @EnvironmentObject var model: PostMock

  var body: some View {
    Form {
      Section {
        NavigationLink {
          CurrentMocksView()
            .environmentObject(PostmanRequestsMocks.shared)
        } label: {
          Text("Current mocks")
        }
      }
      Section {
        if #available(iOS 16.0, *) {
          LabeledContent("Workspace", value: model.workspace?.name ?? model.config.workspaceID)
          LabeledContent("Default collection", value: model.defaultCollection?.name ?? model.config.defaultCollectionID ?? "")
          LabeledContent("Default mock server", value: model.defaultMockServer?.name ?? model.config.defaultMockServerID ?? "")
        }
      }

      Section(header: Text("Current Placeholders values")) {
        ForEach(Array(PostMock.shared.placeholderValues.keys), id: \.self) { key in
          HStack {
            Text("\(key):")
              .bold()
            Text(PostMock.shared.value(forPlaceholder: key) ?? "")
          }
        }
      }
    }
    .navigationTitle("Settings")
  }

}

struct PostmanSettingsView_Previews: PreviewProvider {

  static var previews: some View {
    NavigationView {
      PostmanSettingsView()
        .environmentObject(PostMock.shared)
        .environmentObject(PostmanRequestsMocks.shared)
    }
  }
}

