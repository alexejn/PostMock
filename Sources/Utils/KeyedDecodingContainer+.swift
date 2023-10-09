//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

extension KeyedDecodingContainer {
  func decode<T>(key: KeyedDecodingContainer<K>.Key, or value: T, _ type: T.Type = T.self) -> T where T : Decodable {
    guard let val = try? decodeIfPresent(type, forKey: key) else {
      return value
    }
    return val
  }

  func decodeOrEmpty(_ key: KeyedDecodingContainer<K>.Key) -> String {
    decode(key: key, or: "")
  }
}
