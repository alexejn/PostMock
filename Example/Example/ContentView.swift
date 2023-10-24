//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import PostMock

struct ContentView: View {
  var body: some View {
    NavigationView {
      CategoriesListView()
    }
    .onAppear {
      PostMock.shared.configurate(with: .example)
      PostMock.shared.isEnabled = true
    }
  }
}

extension PostMock.Config {
  static var example = Self(apiKey: "PMAK" + "-651d735b267ab40031e" + "bbbe8-b7109f56a916e1b447e41f84e88575f00d",
                            workspaceID: "f2c801d5-9bbd-4d5e-8984-fa23d3bb10c2")
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
