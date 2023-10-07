import SwiftUI
import PostMock

struct ContentView: View {
  var body: some View {
    NavigationView {
      CategoriesListView()
        .postMockOnShake()
    }
    .onAppear {
      PostMock.shared.configurate(with: .myConfig)
      PostMock.shared.enable()
    }
  }
}

#Preview {
  ContentView()
}

extension PostMockConfig {
  static var myConfig = Self(apiKey: "PMAK-651d735b267ab40031ebbbe8-b7109f56a916e1b447e41f84e88575f00d",
                             workspaceID: "f2c801d5-9bbd-4d5e-8984-fa23d3bb10c2",
                             defaultCollectionID: "1122734-8f8d23a8-f19b-4883-a260-3bcf3bd204f5")
}

