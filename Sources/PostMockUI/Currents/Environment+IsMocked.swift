import SwiftUI

private struct IsMockedKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var isMocked: Bool {
    get { self[IsMockedKey.self] }
    set { self[IsMockedKey.self] = newValue }
  }
}
