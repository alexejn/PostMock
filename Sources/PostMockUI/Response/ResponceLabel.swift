//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct ResponseLabel: View {
  let name: String

  @EnvironmentObject var postMock: PostMock
  @EnvironmentObject var model: CollectionsViewModel
  @Environment(\.isMocked) var isMocked

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Image(systemName: "note.text")
      Text(name)
        .font(.headline.monospacedIOS14().weight(.light))
        .multilineTextAlignment(.leading)
      Spacer()
    }
    .foregroundColor(isMocked ? .accentColor : .primary)
    .opacity(!postMock.mockIsEnabled && isMocked ? 0.3 : 1)
    .padding(.vertical, 1)
  }
}

struct ResponseLabel_Previews: PreviewProvider {
  
  static let model = CollectionsViewModel(.sample)
  static let mocks = PostMock.shared

  static var previews: some View {
    VStack {
      ResponseLabel(name: "200: Ok")
      ResponseLabel(name: "404: Not Found")
        .environment(\.isMocked, true)
    }
    .padding()
    .environmentObject(model)
    .environmentObject(mocks)

  }
}
