//
// Created by Alexey Nenastyev on 5.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

struct EnvironmentView: View {
  @EnvironmentObject var model: PostMock

  var body: some View {
    Form {
        Section(header: Text("Request")) {
          ForEach(Array(PostMock.shared.environment.keys(for: .request)), id: \.self) { key in
            LabeledContent(title: key,
                           value: PostMock.shared.environment[key] ?? "")
          }
        }
        Section(header: Text("Mock")) {
          ForEach(Array(PostMock.shared.environment.keys(for: .mock)), id: \.self) { key in
            LabeledContent(title: key, 
                           value: PostMock.shared.environment[key] ?? "")
          }
        }
    }
    .navigationTitle("Environment")
  }
}

struct LabeledContent: View {
  let title: String
  let value: String

  var body: some View {
    if #available(iOS 16.0, *) {
      LabeledContent(title: title, value: value)
    } else {
      HStack {
        Text("\(title):")
          .bold()
        Text(value)
          .font(.footnote)
      }
    }
  }
}

#Preview {
  NavigationView {
    EnvironmentView()
      .environmentObject(PostMock.shared)
      .environmentObject(MockStorage.shared)
  }
}
