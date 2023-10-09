//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

/// Шаблон постман запроса - используется для опеределения соответсвия между описанием запроса в постмане и реальным которое делает приложение
public struct PostmanRequestPattern: Hashable, CustomStringConvertible, Codable {
  /// HTTP метод ( пример GET)
  let method: String
  /// Плесхолдер для хоста ( дефолтный {{host}} )
  let hostPlaceholder: String
  /// Часть пути без хоста и параметров ( пример /v1/accounts)
  let path: String
  /// UID запроса постмана которому соответсвует данный паттерн
  let requestUID: String

  public var description: String { "\(method.uppercased()) \(hostPlaceholder)\(path)" }

  public init(method: String, hostPlaceholder: String, path: String, requestUID: String) {
    self.method = method
    self.hostPlaceholder = hostPlaceholder
    self.path = path
    self.requestUID = requestUID
  }

  public func match(request: URLRequest) -> Bool {
    guard let url = request.url,
          let method = request.httpMethod  else { return false }

    let requestUID = request.value(forHTTPHeaderField: PostMock.Headers.xPostmanRequestId)
    let originalMockedHost = request.value(forHTTPHeaderField:PostMock.Headers.xMockedHost)

    return match(url: url, method: method, requestUID: requestUID, originalMockedHost: originalMockedHost)
  }

  private func match(url: URL, method: String, requestUID: String?, originalMockedHost: String?) -> Bool {
    if let requestUID {
      return self.requestUID == requestUID
    }
    guard let host = url.host else { return false }
    let hostPart = originalMockedHost ?? host
    let urlPattern = "\(method.uppercased()) \(hostPart)\(url.path)"
    let hostPlaceholderValue = PostMock.shared.value(forPlaceholder: hostPlaceholder)
    let pattern = "\(self.method.uppercased()) \(hostPlaceholderValue ?? hostPart)\(path)"
    return PostmanRequestPattern.matchURL(urlPattern, postmanURLPath: pattern)
  }

  private static func extractComponents(from input: String) -> (String, String, String, String)? {
      // Разделяем строку на компоненты по пробелам
      let components = input.components(separatedBy: " ")

      guard components.count >= 3 else {
          return nil
      }

      // Первый компонент всегда A
      let A = components[0]

      // Второй компонент вида B/C
      let BAndC = components[1]
      let BCComponents = BAndC.components(separatedBy: "/")

      guard BCComponents.count == 2 else {
          return nil
      }

      let B = BCComponents[0]
      let C = BCComponents[1]
      let D = components[2]

      return (A, B, C, D)
  }

  // swiftlint:disable all
  private static func matchURL(_ url: String, postmanURLPath pattern: String) -> Bool {
    let patternComponents = pattern.components(separatedBy: "/")
    let urlComponents = url.components(separatedBy: "/")

    guard patternComponents.count == urlComponents.count else {
      return false
    }

    for (index, patternComponent) in patternComponents.enumerated() {
      let urlComponent = urlComponents[index]

      if patternComponent.hasPrefix("{{") && patternComponent.hasSuffix("}}") {
        // Если компонент шаблона находится в фигурных скобках
        let variablePattern = patternComponent.dropFirst(2).dropLast(2)
        let regexString = "[a-zA-Z0-9]+"

        if variablePattern.isEmpty {
          // Пустой шаблон означает любую последовательность
          continue
        } else {
          let regex = try! NSRegularExpression(pattern: regexString)
          let range = NSRange(location: 0, length: urlComponent.utf16.count)
          guard regex.firstMatch(in: urlComponent, options: [], range: range) != nil else {
            return false
          }
        }
      } else if patternComponent != urlComponent {
        // Если компоненты не совпадают и не являются переменными
        return false
      }
    }

    return true
  }
  // swiftlint:enable all
}
