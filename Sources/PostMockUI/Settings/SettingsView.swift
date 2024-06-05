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
          ConfigurationsView()
            .environmentObject(PostMock.shared)
        } label: {
          Text("Configurations")
        }

        NavigationLink {
          CurrentMocksView()
            .environmentObject(MockStorage.shared)
        } label: {
          LabeledContent(title: "Current mocks", value: "\(MockStorage.shared.mocked.count)")
        }
      }
    }
  }

}

struct PostmanSettingsView_Previews: PreviewProvider {

  static var previews: some View {
    NavigationView {
      PostmanSettingsView()
        .environmentObject(PostMock.shared)
        .environmentObject(MockStorage.shared)
    }
  }
}
