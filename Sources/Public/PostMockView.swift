//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

public struct PostMockView: View {
  @StateObject var model = PostMock.shared
  @StateObject var mocks = PostmanRequestsMocks.shared

  public init() {}

  public var body: some View {
    NavigationView {
      Group {
        if model.isLoading {
          ProgressView()
        } else if model.workspace != nil {
          if let collection = model.collection {
            VStack(alignment: .leading) {
              Divider()

              HStack(alignment: .center, spacing: 0) {
                Picker("", selection: $model.collection) {
                  ForEach(model.collections, id: \.id) {
                    Text($0.name)
                      .font(.headline)
                      .tag($0 as Workspace.Collection?)
                  }
                }
                .pickerStyle(.automatic)
                .padding(.leading, 10)
                .disabled(model.isLoading)
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
                    Picker("Mock Server", selection: $model.mockServer) {
                      ForEach(model.collectionMockServers, id: \.id) {
                        Text($0.name)
                          .tag($0 as MockServer?)
                      }
                    }
                    .pickerStyle(.menu)
                    .disabled(!model.mockIsEnabled)
                    .opacity(model.mockIsEnabled ? 1 : 0.5)
                  }
                }.opacity(model.isLoading ? 0 : 1 )
              }.frame(height: 30)
              .animation(.default, value: model.mockServer)
              CollectionView(collection: collection)
              Spacer()
            }

          } else {
            Text("No collections")
          }
        }
        else if let error = model.error {
          Text(error)
        } else {
          Text("No data")
        }
      }
      .toolbar {

        ToolbarItem(placement: .leftCorner) {
          Toggle("Mock", isOn: $model.mockIsEnabled)
            .toggleStyle(SwitchToggleStyle(tint: Color.blue))
        }

        ToolbarItem(placement: .rightCorner) {
          ReloadButton(isLoading: model.isLoading,
                       reload: model.reload)
        }

        ToolbarItem(placement: .rightCorner) {
          NavigationLink {
            CallsView()
              .environmentObject(model)
              .environmentObject(mocks)
          } label: {
            Image(systemName: "list.bullet.rectangle")
          }
        }


        ToolbarItem(placement: .rightCorner) {
          NavigationLink {
            PostmanSettingsView()
              .environmentObject(model)
              .environmentObject(mocks)
          } label: {
            Image(systemName: "gear")
          }
        }
      }
      .environmentObject(model)
      .environmentObject(mocks)
#if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
#endif
      .onFirstAppear {
        Task { @MainActor in
          guard !model.isLoaded else { return }
          await model.load()
        }
      }
    }
  }
}

extension ToolbarItemPlacement {
  static var rightCorner: ToolbarItemPlacement {
    #if os(iOS)
    return .navigationBarTrailing
    #endif
    #if os(macOS)
    return .confirmationAction
    #endif
  }

  static var leftCorner: ToolbarItemPlacement {
    #if os(iOS)
    return .navigationBarLeading
    #endif
    #if os(macOS)
    return .primaryAction
    #endif
  }
}

struct ReloadButton: View {

  @State private var isReloadRotating = 0.0

  var isLoading: Bool
  var reload: () -> Void

  var body: some View {
    Button(action: reload) {
      Image(systemName: "arrow.triangle.2.circlepath")
        .rotationEffect(.degrees(isReloadRotating))
    }
    .disabled(isLoading)
    .onAppear {
      guard isLoading else { return }
      withAnimation(.linear(duration: 3)
        .repeatForever(autoreverses: false)) {
          isReloadRotating = 360.0
        }
    }
  }
}

struct PostmanView_Previews: PreviewProvider {
  static var previews: some View {
    PostMockView()
  }
}
