//
//  FactView.swift
//  Demo
//
//  Created by Alexey Nenastev on 10.6.24..
//

import SwiftUI

struct FactView: View {
  @StateObject var fact = Fact()
  var body: some View {
    HStack {
      if let fact = fact.facts.first?.attributes.body {
        Text(fact)
      } else {
        Spacer()
      }
      Button("Reload") {
        Task {
          await fact.load()
        }
      }
      .buttonStyle(.bordered)
    }
  }
}


final class Fact: ObservableObject {
  @Published var facts: [FactsResponse.Fact] = []
  @Published var isLoading: Bool = false

  init() {
    print("init fact")
    Task {
      await load()
    }
  }

  @MainActor
  func load() async {
    defer { isLoading = false }
    isLoading = true
    let req = URLRequest(url: URL(string: "https://dogapi.dog/api/v2/facts")!)
    do {
      /// Used shared url session
      let (data, _) = try await URLSession.shared.data(for: req)
      self.facts = try JSONDecoder().decode(FactsResponse.self, from: data).data
    } catch {
      print(error)
    }
  }
}

struct FactsResponse: Codable {
  let data: [Fact]

  struct Fact: Codable {
    let attributes: Attributes
    struct Attributes: Codable {
      let body: String
    }
  }
}

#Preview {
  FactView()
}
