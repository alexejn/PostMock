//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Combine
import Foundation
import os

@propertyWrapper
/// Обертка над UserDefaults
public struct UserDefault<Value: Codable> {
  let key: String
  let defaultValue: Value
  var container: UserDefaults
  private let publisher = PassthroughSubject<Value, Never>()

  public init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
    self.key = key
    self.defaultValue = defaultValue
    self.container = container
  }

  public var wrappedValue: Value {
    get {
      return container.decode(forKey: key) ?? defaultValue
    }
    set {
      // Check whether we're dealing with an optional and remove the object if the new value is nil.
      if let optional = newValue as? AnyOptional, optional.isNil {
        container.removeObject(forKey: key)
      } else {
        container.set(codable: newValue, forKey: key)
      }
      publisher.send(newValue)
    }
  }

  public var projectedValue: AnyPublisher<Value, Never> {
    return publisher.eraseToAnyPublisher()
  }
}

protocol AnyOptional {
  /// Returns `true` if `nil`, otherwise `false`.
  var isNil: Bool { get }
}

extension Optional: AnyOptional {
  public var isNil: Bool { self == nil }
}

extension UserDefaults {
  func set<C: Encodable>(codable: C, forKey key: String) {
    do {
      if let optional = codable as? AnyOptional, optional.isNil {
        removeObject(forKey: key)
      } else {
        let encoded = try PropertyListEncoder().encode(codable)
        set(encoded, forKey: key)
      }
    } catch {
      Logger.postmock.error("UserDefault encoding error \(error)")
    }
  }

  func decode<T: Decodable>(_ type: T.Type = T.self, forKey key: String) -> T? {
    if let savedData = object(forKey: key) {

      do {
        guard let data = savedData as? Data, !data.isEmpty else { return nil }
        let decoded = try PropertyListDecoder().decode(type, from: data)
        return decoded
      } catch {
        removeObject(forKey: key)
        Logger.postmock.error("UserDefault decoding error key:\(key) type:\(type) \(error)")
        return nil
      }
    } else {
      return nil
    }

  }
}
