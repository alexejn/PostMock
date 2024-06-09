//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import PostMockSDK

struct ContentView: View {
  var body: some View {
    NavigationView {
      DogsList()
    }
    .onAppear {
      PostMock.shared.configurate(with: .example)
    }
  }
}

extension PostMock.Config {
  static var example = Self(apiKey: "PMAK" + "-651d735b267ab40031ebbbe8" + "-1614e1ff4c7bdb777cdee5187dd2722c61",
                            workspaceID: "f2c801d5-9bbd-4d5e-8984-fa23d3bb10c2")
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
