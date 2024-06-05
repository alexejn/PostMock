//
// Created by Alexey Nenastyev on 4.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

struct BreedView: View {
  var breed: Breed

  var body: some View {
    VStack(alignment: .leading) {
      Text(breed.attributes.name)
        .font(.headline)
      Text(breed.attributes.description)
        .font(.subheadline)
    }
  }
}
