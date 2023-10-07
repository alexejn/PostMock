import SwiftUI

struct PostmanSettingsView: View {
  @EnvironmentObject var model: PostMock

  var body: some View {
    Form {
      Section {
        NavigationLink {
          CallsView()
        } label: {
          Text("All calls")
        }

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

