//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

public struct MockServer: Codable, Hashable {
  let id: String
  let host: String
  let name: String
  let collection: String

  init(id: String, name: String, host: String, collectionUID: String) {
    self.name = name
    self.host = host
    self.id = id 
    self.collection = collectionUID
  }
}

public extension MockServer {
  /// Host, without http://
  /// example: 0997c312-c8ea-435a-8ffd-4a98f4214024.mock.pstmn.io
  init(host: String) {
    self.init(id: "", name: "", host: host, collectionUID: "")
  }
}
