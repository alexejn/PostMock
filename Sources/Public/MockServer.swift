//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

public struct MockServer: Codable, Hashable, Identifiable {
  public let id: String
  public let name: String
  public let host: String
  public let collection: String

  init(id: String, name: String, host: String, collection: String) {
    self.name = name
    self.host = host
    self.id = id 
    self.collection = collection
  }
}
