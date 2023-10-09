//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct CurrentMocksView: View {

  @EnvironmentObject var mocks: PostmanRequestsMocks

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        ForEach(mocks.mocked, id: \.self) { pattern in
          HStack {
            Text(pattern.description)
            Spacer()
          }
        }
      }
      .padding(.horizontal)
    }
    .toolbar {
      ToolbarItem(placement: .rightCorner) {
        Button("Clear", action: {
          mocks.clearAll()
        })
      }
    }
    .navigationTitle("Current mocks")
  }
}

struct CurrentMocksView_Previews: PreviewProvider {
  static var previews: some View {
    CurrentMocksView()
      .environmentObject(PostmanRequestsMocks.shared)
  }
}
