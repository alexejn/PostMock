import Combine
import Foundation

@propertyWrapper
/// Обертка над UserDefaults
struct UserDefault<Value: Codable> {
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
      let encoded = try JSONEncoder().encode(codable)
      set(encoded, forKey: key)
    } catch {
      print("---EncodeError \(error)")
    }
  }

  func decode<T: Decodable>(_ type: T.Type = T.self, forKey key: String) -> T? {
    if let savedData = object(forKey: key) {

      do {
        guard let data = savedData as? Data else { return nil }
        let decoded = try JSONDecoder().decode(type, from: data)
        return decoded
      } catch {
        print("---DecodeError \(error)")
        return nil
      }
    } else {
      return nil
    }

  }
}
