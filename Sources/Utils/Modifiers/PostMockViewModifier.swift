//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

#if os(iOS)
private struct PostMockViewModifier: ViewModifier {
  @State private var viewVisible = false

  func body(content: Content) -> some View {
    content
      .onShake(perform: {
        viewVisible = true
      })
      .sheet(isPresented: $viewVisible, content: {
        PostMockView()
      })
  }
}

public extension View {
  func postMockOnShake() -> some View {
    modifier(PostMockViewModifier())
  }
}
#endif
