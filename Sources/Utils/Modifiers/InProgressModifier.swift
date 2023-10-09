//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

/// Модификатор реализует аналог  viewDidLoad
struct InProgressModifier: ViewModifier {

  var inProgress: Bool

  func body(content: Content) -> some View {
    if inProgress {
      ProgressView()
    } else {
      content
    }
  }
}

extension View {
  func progress(_ inProgress: Bool) -> some View {
    modifier(InProgressModifier(inProgress: inProgress))
  }
}
