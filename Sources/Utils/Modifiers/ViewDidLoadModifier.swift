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

