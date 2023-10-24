//
// Created by Alexey Nenastyev on 10.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

struct WorkspaceView: View {

  @StateObject var model: WorkspaceModel
  @EnvironmentObject var mocks: PostmanRequestsMocks
  @EnvironmentObject var postMock: PostMock

  public var body: some View {
      Group {
        if model.isWorkspaceLoading {
          ProgressView()
        } else if model.workspace != nil {
          if let collection = model.collection {
            VStack(alignment: .leading) {
              Divider()

              HStack(alignment: .center, spacing: 0) {
                Picker("", selection: $model.currentCollectionUID) {
                  ForEach(model.collections, id: \.id) {
                    Text($0.name)
                      .font(.headline)
                      .tag($0.uid as String?)
                  }
                }
                .pickerStyle(.automatic)
                .padding(.leading, 10)
                .disabled(model.isWorkspaceLoading)
                .foregroundColor(.black)

                Divider()
                  .frame(height: 10)
                Group {
                  if model.collectionMockServers.isEmpty {
                    Text("No Mock Servers")
                      .font(.footnote)
                      .padding(.horizontal)
                      .foregroundColor(.red.opacity(0.6))
                  } else {
                    Picker("Mock Server", selection: $model.currentMockServerID) {
                      ForEach(model.collectionMockServers, id: \.id) {
                        Text($0.name)
                          .tag($0.id as String?)
                      }
                    }
                    .pickerStyle(.menu)
                    .disabled(!postMock.mockIsEnabled)
                    .opacity(postMock.mockIsEnabled ? 1 : 0.5)
                  }
                }
                .opacity(model.isWorkspaceLoading ? 0 : 1 )
              }
              .frame(height: 30)
              .animation(.default, value: model.currentMockServerID)
              CollectionView(collection: collection)
              Spacer()
            }

          } else {
            Text("No collections")
          }
        }
        else if let error = model.loadError {
          Text(error)
        } else {
          Text("No data")
        }
      }
      .toolbar {

        ToolbarItem(placement: .navigationBarLeading) {
          Toggle("Mock", isOn: $postMock.mockIsEnabled)
            .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          ReloadButton(isLoading: model.isWorkspaceLoading,
                       reload: model.reload)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink {
            CallsView()
              .environmentObject(model)
              .environmentObject(mocks)
              .environmentObject(postMock)
          } label: {
            Image(systemName: "list.bullet.rectangle")
          }
        }


        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink {
            PostmanSettingsView()
              .environmentObject(model)
              .environmentObject(mocks)
              .environmentObject(postMock)
          } label: {
            Image(systemName: "gear")
          }
        }
      }
      .environmentObject(model)
      .environmentObject(mocks)
      .environmentObject(postMock)
      .navigationBarTitleDisplayMode(.inline)
  }
}


struct WorkspaceView_Previews: PreviewProvider {
  static var previews: some View {
    WorkspaceView(model: WorkspaceModel(workspaceID: PostMock.Config.empty.workspaceID))
      .environmentObject(PostMock.shared)
      .environmentObject(PostmanRequestsMocks.shared)
  }
}
