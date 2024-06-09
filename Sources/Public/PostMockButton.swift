//
// Created by Alexey Nenastyev on 4.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

struct PostMockButton: ViewModifier {

  @State private var presented = false
  var insets: EdgeInsets

  func body(content: Content) -> some View {
    content
      .overlayIOS14(alignment: .bottomTrailing) {
        Button("PostMock") {
          presented.toggle()
        }
        .padding(10)
        .background(Color.orange)
        .padding(insets)
        .buttonStyle(.plain)
      }
      .fullScreenCover(isPresented: $presented, content: {
        PostMockView()
      })
  }
}

public extension View {
  func overlayPostMockButton(insets: EdgeInsets = .init(top: 0, leading: 0, bottom: 20, trailing: -10)) -> some View {
    modifier(PostMockButton(insets: insets))
  }
}
