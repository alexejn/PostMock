//
// Created by Alexey Nenastyev on 10.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import os
import Foundation

extension Storage.File {
  static func workspace(workspaceID: String) -> Self {
    .init(filename: "workspace-\(workspaceID).data")
  }

  static func collection(collectionUID: String) -> Self {
    .init(filename: "collection-\(collectionUID).data")
  }

  static func mockServers(workspaceID: String) -> Self {
    .init(filename: "mocks-\(workspaceID).data")
  }

  static var configurateion: Self {
    .init(filename: "configurations.data")
  }
}
