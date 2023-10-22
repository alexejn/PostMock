//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

public extension PostMock {
  struct Config: Codable, Hashable, Identifiable  {
    public var id: String { apiKey + workspaceID }
    var name: String
    public var apiKey: String
    public var workspaceID: String

    public init(name: String = "",
                apiKey: String,
                workspaceID: String) {
      self.name = name
      self.apiKey = apiKey
      self.workspaceID = workspaceID
    }

    var valid: Bool {
      !apiKey.isEmpty && !workspaceID.isEmpty
    }

    static var empty = Self(apiKey: "", workspaceID: "")
  }
}
