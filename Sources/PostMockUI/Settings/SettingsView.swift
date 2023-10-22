//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct PostmanSettingsView: View {
  @EnvironmentObject var model: PostMock

  @ViewBuilder
  private func labeledContent(_ title: String, value: String) -> some View {
    if #available(iOS 16.0, *) {
      LabeledContent(title, value: value)
    } else {
      HStack {
        Text("\(title):")
          .bold()
        Text(value)
          .font(.footnote)
      }
    }
  }

  var body: some View {
    Form {
      Section {
        NavigationLink {
          ConfigurationsView()
            .environmentObject(PostMock.shared)
        } label: {
          Text("Configurations")
        }

        NavigationLink {
          CurrentMocksView()
            .environmentObject(PostmanRequestsMocks.shared)
        } label: {
          labeledContent("Current mocks", value: "\(PostmanRequestsMocks.shared.mocked.count)")
        }
      }

      Section(header: Text("Placeholders")) {
        ForEach(Array(PostMock.shared.placeholderValues.keys), id: \.self) { key in
          labeledContent(key, value: PostMock.shared.value(forPlaceholder: key) ?? "")
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

