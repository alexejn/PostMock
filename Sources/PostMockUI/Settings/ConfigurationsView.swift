//
// Created by Alexey Nenastyev on 11.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

struct ConfigurationsView: View {
  @ObservedObject var model: PostMock = .shared
  @State var isPresented:  Bool = false
  @State var newConfig: PostMock.Config = .empty

  struct ConfigItem: View {
    let config: PostMock.Config
    let selected: Bool

    var body: some View {
      HStack {
        VStack(alignment: .leading) {
          Text(config.name)
            .font(.title2)
            .bold()
            .padding(.vertical, 2)
          Text("**API-KEY:** \(config.apiKey)")
          Text("**WorkspaceID:** \(config.workspaceID)")
          Spacer()

        }
        .lineLimit(1)
        .font(.footnote)
        Spacer()
        if selected {
          Image(systemName: "checkmark")
            .foregroundColor(.accentColor)
        }
      }
    }
  }

  private func configItem(config: PostMock.Config) -> some View {
    ConfigItem(config: config, selected: model.config == config)
      .onTapGesture {
        model.config = config
      }
  }

  var body: some View {
    List {
      if model.baseConfig != .empty  {
        Section {
          configItem(config: model.baseConfig)
        } header: {
          Text("Base")
        }
      }

      if !model.storedConfigs.isEmpty {
        Section {
          ForEach(model.storedConfigs) { config in
            configItem(config: config)
          }.onDelete { indexSet in
            let index = indexSet[indexSet.startIndex]
            let config = model.storedConfigs[index]
            model.storedConfigs.remove(atOffsets: indexSet)
            if model.config == config {
              model.config = model.baseConfig
            }
          }
        } header: {
          Text("Custom")
        }
      }

      Button("Add New") {
        isPresented.toggle()
      }
    }
    .animation(.default, value: model.config)
    .sheet(isPresented: $isPresented, content: {
      Form(content: {
        Section {
          TextField("Name", text: $newConfig.name)
          TextField("API-KEY", text: $newConfig.apiKey)
          TextField("WorkspaceID", text: $newConfig.workspaceID)
        }
        Button("Save") {
          model.storedConfigs.append(newConfig)
          model.config = newConfig
          isPresented = false
        }.disabled(!newConfig.valid)
      })
    })

  }
}

struct ConfigurationsView_Previews: PreviewProvider {

  static var previews: some View {
    PostMock.shared.storedConfigs = [ .sample1, .sample2]
    return NavigationView {
      ConfigurationsView()
    }
  }
}

private extension PostMock.Config {
  static var sample1 = Self(name: "Jack", apiKey: "32231231231231s", workspaceID: "321231213")
  static var sample2 = Self(name: "Kate", apiKey: "21safadasda12d1", workspaceID: "321231213")
}
