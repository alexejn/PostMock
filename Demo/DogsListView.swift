//
// Created by Alexey Nenastyev on 4.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import SwiftUI
import Observation

struct DogsList: View {
  @StateObject private var dogs = Dogs()

  var body: some View {
    NavigationStack {
      ZStack {
        if let message = dogs.message {
          Text(message)
        }

        List {

          Section("Interesting fact...") {
            FactView()
          }

          Section("Breeds") {
            ForEach(dogs.breed, id: \.id) { breed in
              NavigationLink(breed.attributes.name)  {
                BreedView(breedID: breed.id)
              }
            }
          }
        }

        if dogs.isLoading {
          ProgressView()
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Dogs App")
      .refreshable {
        Task {
          await dogs.load(page: dogs.currentPage)
        }
      }
      .toolbar {

        
        ToolbarItem(placement: .bottomBar) {
          HStack {
            
            Button("Prev") {
              Task {
                await dogs.load(page: dogs.currentPage-1)
              }
            }
            .disabled(dogs.currentPage == 1)
            Text("\(dogs.currentPage)")
            Button("Next") {
              Task {
                await dogs.load(page: dogs.currentPage+1)
              }
            }
          }
        }
      }
    }
  }
}

final class Dogs: ObservableObject {
 @Published var breed: [Breed] = []
 @Published var isLoading: Bool = false
 @Published var message: String?
 private(set) var currentPage = 1

  init() {
    Task {
      await load()
    }
  }

  @MainActor
  func load() async {
    defer { isLoading = false }
    breed = []
    isLoading = true
    let req = URLRequest(url: URL(string: "https://dogapi.dog/api/v2/breeds")!)
    do {
      /// Used shared url session
      let (data, _) = try await URLSession.shared.data(for: req)
      self.breed = try JSONDecoder().decode(BreedsResponse.self, from: data).data
    } catch {
      message = "\(error)"
    }
  }

  @MainActor
  func load(page: Int) async {
    defer { isLoading = false }
    breed = []
    isLoading = true
    currentPage = page
    let req = URLRequest(url: URL(string: "https://dogapi.dog/api/v2/breeds?page[number]=\(page)")!)
    do {
      /// Used shared url session
      let (data, _) = try await URLSession.shared.data(for: req)
      self.breed = try JSONDecoder().decode(BreedsResponse.self, from: data).data
    } catch {
      message = "\(error)"
    }
  }
}

struct BreedsResponse: Codable {
  let data: [Breed]
}

struct BreedResponse: Codable {
  let data: Breed
}


struct Breed: Codable {
  typealias ID = String
  let id: ID
  let type: String
  let attributes: Attributes

  struct Attributes: Codable {
    let name: String
    let description: String
    let hypoallergenic: Bool
    let life: Life

    struct Life: Codable {
      let min: Int
      let max: Int
    }
  }
}

#Preview {
  DogsList()
}
