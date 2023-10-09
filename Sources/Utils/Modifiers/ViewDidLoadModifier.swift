//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

/// Модификатор реализует аналог  viewDidLoad
struct ViewDidLoadModifier: ViewModifier {

  @State private var didLoad = false
  private let action: (() -> Void)?

  init(perform action: (() -> Void)? = nil) {
    self.action = action
  }

  func body(content: Content) -> some View {
    content.onAppear {
      if didLoad == false {
        didLoad = true
        action?()
      }
    }
  }
}

extension View {
  func onFirstAppear(action: @escaping () -> Void) -> some View {
    modifier(ViewDidLoadModifier(perform: action))
  }
}

