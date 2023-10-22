//
// Created by Alexey Nenastyev on 10.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

struct ReloadButton: View {

  @State private var isReloadRotating = 0.0

  var isLoading: Bool
  var reload: () -> Void

  var body: some View {
    Button(action: reload) {
      Image(systemName: "arrow.triangle.2.circlepath")
        .rotationEffect(.degrees(isReloadRotating))
    }
    .disabled(isLoading)
    .onAppear {
      guard isLoading else { return }
      withAnimation(.linear(duration: 3)
        .repeatForever(autoreverses: false)) {
          isReloadRotating = 360.0
        }
    }
  }
}
