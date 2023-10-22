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
//      PostMock.shared.configurate(with: PostMock.Config(
//        apiKey: // place your api-key here,
//        workspaceID: // place your workspace id here))

      PostMock.shared.isEnabled = true
    }
  }
}

#Preview {
  ContentView()
}
