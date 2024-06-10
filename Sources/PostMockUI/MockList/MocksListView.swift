//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct CurrentMocksView: View {

  @ObservedObject var mocks: MockStorage = .shared

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        ForEach(mocks.mocked, id: \.self) { template in
          HStack {
            Text(template.actualDescription)
            Spacer()
          }
        }
      }
      .padding(.horizontal)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          mocks.clearAll()
        } label: {
          Image(systemName: "trash")
        }
      }
    }
    .navigationTitle("Current mocks")
  }
}

struct CurrentMocksView_Previews: PreviewProvider {
  static var previews: some View {
    CurrentMocksView()
  }
}
