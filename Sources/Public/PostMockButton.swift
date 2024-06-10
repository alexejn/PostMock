//
// Created by Alexey Nenastyev on 4.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

struct PostMockButton: ViewModifier {

  @State private var presented = false
  var insets: EdgeInsets

  func body(content: Content) -> some View {
    ZStack(alignment: .bottomTrailing) {
      content
      Button("PostMock") {
        presented.toggle()
      }
      .padding(10)
      .background(Color.orange.opacity(0.4))
      .padding(insets)
      .buttonStyle(.plain)
    }
    .sheet(isPresented: $presented, content: {
      PostMockView()
    })
  }
}

public extension View {
  func overlayPostMockButton(insets: EdgeInsets = .init(top: 0, leading: 0, bottom: 60, trailing: -10)) -> some View {
    modifier(PostMockButton(insets: insets))
  }
}
