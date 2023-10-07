import SwiftUI

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
