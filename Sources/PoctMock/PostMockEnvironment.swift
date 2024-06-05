//
// Created by Alexey Nenastyev on 5.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public final class PostMockEnvironment: ObservableObject {
  public typealias ValueProvider = () -> String

  public enum Scope: Int, Codable {
    case mock
    case request
  }

  @UserDefault(key: "postmock.environment", defaultValue: [:])
  private(set) var values: [String: String]

  private(set) var providers: [String: ValueProvider] = [:]

  @UserDefault(key: "postmock.environment.scope", defaultValue: [:])
  private(set) var scopes: [String: Scope]


  public func set(value: String, scope: Scope, for key: String) {
    values[key] = value
    scopes[key] = scope
  }

  public func set(key: String, scope: Scope, provider: @escaping ValueProvider) {
    providers[key] = provider
    scopes[key] = scope
  }

  public subscript(key: String, scope: Scope? = nil) -> String? {
    guard scope == nil || scopes[key] == nil || scopes[key]!.rawValue <= scope!.rawValue else { return nil }

    return values[key] ?? providers[key]?()
  }

  public func clear(key: String) {
    values.removeValue(forKey: key)
    scopes.removeValue(forKey: key)
    providers.removeValue(forKey: key)
  }

  func keys(for scope: Scope) -> [String] {
    values.keys.filter { scopes[$0] == scope }
  }

  static let shared = PostMockEnvironment()
}
