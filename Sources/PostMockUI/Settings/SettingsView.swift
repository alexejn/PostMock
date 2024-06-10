//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct PostmanSettingsView: View {

  var body: some View {
    Form {
      Section {
        NavigationLink {
          ConfigurationsView()
        } label: {
          Text("Configurations")
        }

        NavigationLink {
          CurrentMocksView()
        } label: {
          Text("Mocked")
        }
      }
    }
  }

}

struct PostmanSettingsView_Previews: PreviewProvider {

  static var previews: some View {
    NavigationView {
      PostmanSettingsView()
    }
  }
}
