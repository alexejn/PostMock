//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

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
