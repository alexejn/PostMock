//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import PostMockSDK

struct ContentView: View {
  var body: some View {
    DogsList()
      .overlayPostMockButton()
      .onAppear {
        PostMock.shared.configurate(with: .example)
        PostMock.shared.environment.set(key: "host",
                                        scope: .request,
                                        provider: { "https://dogapi.dog" })
      }
  }
}

/// Our workspace for play
/// https://www.postman.com/universal-moon-430028/workspace/postmock

/// To generate api_key you can use this instauctions
/// https://learning.postman.com/docs/developer/postman-api/authentication/
extension PostMock.Config {
  static var example = Self(apiKey: "<POSTMAN_API_KEY>",
                            workspaceID: "05ffed39-33b2-412f-ab4d-b234ad8539b7")
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
