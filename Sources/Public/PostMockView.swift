//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import PulseUI

//public struct PostMockView: View {
//  public var body: some View {
//    TabView {
//      _PostMockView()
//        .tabItem { Text("Mocks") }
//
////      NavigationView {
////        Text("")
////        .navigationBarTitleDisplayMode(.inline)
////      }
////        .tabItem { Label("Environment", systemImage:  "chandelier") }
//
////      NavigationView {
////        ConsoleView()
////        .navigationBarTitleDisplayMode(.inline)
////      }
////        .tabItem { Label("Network", systemImage:  "network") }
//    }
//
//    .navigationBarTitleDisplayMode(.inline)
//  }
//}

public struct PostMockView: View {
  @StateObject var model = PostMock.shared
  @StateObject var mocks = MockStorage.shared

  public init() {}

  public var body: some View {
    NavigationView {
      let config = model.config
      if model.configured {
        
        WorkspaceView(model: WorkspaceModel(workspaceID: config.workspaceID))
          .id(config.workspaceID)
          .environmentObject(model)
          .environmentObject(mocks)
      } else {
        ZStack(alignment: .topLeading) {
          Color.clear
          VStack(alignment: .leading) {
            Text("Not configured.")
              .font(.body)
            NavigationLink("Add new configuration") {
              ConfigurationsView()
                .environmentObject(model)
            } .font(.body)
            Spacer()
              .frame(height: 20)
            Text("Your can also configurate programatically from code calling:")
            Text("PostMock.configurate(with:)")
              .font(.headline.monospacedIOS14())

          }
          .font(.callout)
          .padding()
          .navigationBarTitleDisplayMode(.inline)
        }
      }
    }
  }
}

struct PostmanView_Previews: PreviewProvider {
  static var previews: some View {
    PostMockView()
  }
}
