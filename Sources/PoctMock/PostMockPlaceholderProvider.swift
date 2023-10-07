//
//  PostMockPlaceholderProvider.swift
//
//
//  Created by Alexey Nenastev on 2.10.23..
//

import Foundation

public struct PostMockPlaceholderProvider {
  public typealias ValueProvider = () -> String

  var placeholderValues: [String: ValueProvider]

  public init(placeholderValues: [String: () -> String]) {
    self.placeholderValues = placeholderValues
  }

  public subscript(_ key: String) -> ValueProvider? {
    get { placeholderValues[key] }
    set { placeholderValues[key] = newValue }
  }


  public static var shared = PostMockPlaceholderProvider(placeholderValues: [:])
}
