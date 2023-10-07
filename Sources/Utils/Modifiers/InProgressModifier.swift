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
