//
// Created by Alexey Nenastyev on 4.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import SwiftUI
import PostMock
import Observation

struct DogsList: View {
  @State private var dogs = Dogs()

  var body: some View {
    NavigationStack {
      ZStack {
        if let message = dogs.message {
          Text(message)
        }

        List {
          Section {
            HStack {
              Button("Reload") {
                Task {
                  await dogs.load()
                }
              }
            }
          }
          .foregroundColor(.mint)
          .buttonStyle(.bordered)

          Section("Breeds") {
            ForEach(dogs.breed, id: \.id) { breed in
              BreedView(breed: breed)
            }
          }
        }

        if dogs.isLoading {
          ProgressView()
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Dogs API")
      .task {
        await dogs.load()
      }
      .overlayPostMockButton()
    }
  }
}

@Observable class Dogs {
  var breed: [Breed] = []
  var isLoading: Bool = false
  var message: String?

  init() {}

  @MainActor
  func load() async {
    defer { isLoading = false }
    breed = []
    isLoading = true
    let req = URLRequest(url: URL(string: "https://dogapi.dog/api/v2/breeds")!)
    do {
      /// Used shared url session
      let (data, _) = try await URLSession.shared.data(for: req)
      self.breed = try JSONDecoder().decode(BreedResponse.self, from: data).data
    } catch {
      message = "\(error)"
    }
  }
}

struct BreedResponse: Codable {
  let data: [Breed]
}

struct Breed: Codable {
  let id: String
  let type: String
  let attributes: Attributes

  struct Attributes: Codable {
    let name: String
    let description: String
  }
}

#Preview {
  DogsList()
}
