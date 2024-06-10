//
// Created by Alexey Nenastyev on 4.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Observation

struct BreedView: View {
  @StateObject var model: BreedModel

  init(breedID: Breed.ID) {
    self._model = StateObject(wrappedValue: BreedModel(breedID: breedID))
  }


  var body: some View {
    if let breed = model.breed {
      VStack(alignment: .leading, spacing: 10) {
        Text(breed.attributes.name)
          .font(.largeTitle)
        Text("life: \(breed.attributes.life.min) - \(breed.attributes.life.max)")
          .font(.footnote)
        HStack  {
          LabeledContent("ID", value: breed.id)
          Button(action: {
            UIPasteboard.general.string = breed.id
          }) {
            Image(systemName: "doc.on.doc")
          }
        }
        Text(breed.attributes.description)

        HStack {
          if breed.attributes.hypoallergenic {
            Text("hypoallergenic")
              .font(.callout)
              .padding(.horizontal, 10)
              .padding(.vertical, 4)
              .background(Color.mint.opacity(0.4).cornerRadius(4))
          }
        }
        Spacer()
      }
      .padding()
    }

    if model.isLoading {
      ProgressView()
    }
  }
}


final class BreedModel: ObservableObject {
  @Published var breed: Breed?
  @Published var isLoading: Bool = false
  let breedID: Breed.ID

  init(breedID: Breed.ID) {
    self.breedID = breedID

    Task {
      await load()
    }
  }

  @MainActor
  func load() async {
    defer { isLoading = false }
    isLoading = true
    let req = URLRequest(url: URL(string: "https://dogapi.dog/api/v2/breeds/\(breedID)")!)
    do {
      /// Used shared url session
      let (data, _) = try await URLSession.shared.data(for: req)
      self.breed = try JSONDecoder().decode(BreedResponse.self, from: data).data
    } catch {
      print(error)
    }
  }
}

#Preview {
  NavigationView {
    BreedView(breedID: "68f47c5a-5115-47cd-9849-e45d3c378f12")
  }
}
