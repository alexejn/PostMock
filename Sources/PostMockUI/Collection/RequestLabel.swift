//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct RequestLabel: View {
  let name: String
  let method: String
  let url: String
  var badge: Int = 0

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 10) {
      Text(method.uppercased())
      .frame(width: 55, alignment: .trailing)
      .foregroundColor(method.methodColor)
      .font(.footnote.weight(.bold))
      VStack(alignment: .leading) {
        Text(name)
          .font(.title3.weight(.regular))
        Text(url
          .replacingOccurrences(of: "?", with: "\n?")
          .replacingOccurrences(of: "&", with: "\n&"))
          .font(.body)
          .foregroundColor(.secondary)


      }
      Spacer()
    }
    .overlayIOS14(alignment: .trailingFirstTextBaseline, content: {
      if badge != 0 {
        Text("\(badge)")
          .foregroundColor(.secondary.opacity(0.5))
      }
    })
    .padding(.vertical, 1)
  }
}

extension View {
  func overlayIOS14<V>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View where V : View {
    if #available(iOS 15.0, *) {
      return self.overlay(alignment: alignment, content: content)
    } else {
      return self.overlay(content(), alignment: alignment)
    }
  }
}

struct RequestLabel_Previews: PreviewProvider {

  static var previews: some View {
    RequestLabel(name: "authorization", method: "GET", url: "v1/oauth/code")
      .padding()
  }
}

