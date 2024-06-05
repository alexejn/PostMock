//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

/// Шаблон постман запроса - используется для опеределения соответсвия между описанием запроса в постмане и реальным которое делает приложение
public struct RequestTemplate: Hashable, CustomStringConvertible, Codable {
  let method: String
  let urlTemplate: URLTemplate
  let requestUID: String

  public var description: String { "\(method.uppercased()) \(urlTemplate)" }
  public var actualDescription: String { "\(method.uppercased()) \(urlTemplate.withValues(for: .request))" }

  public init(method: String, url: String, requestUID: String) {
    self.method = method
    self.urlTemplate = URLTemplate(url: url)
    self.requestUID = requestUID
  }

  public func isMathing(request: URLRequest) -> Bool {
    guard let url = request.url,
          let method = request.httpMethod  else { return false }

    let requestUID = request.value(forHTTPHeaderField: PostMock.Headers.xPostmanRequestId)
    let originalMockedHost = request.value(forHTTPHeaderField:PostMock.Headers.xMockedHost)

    return isMathing(url: url, method: method, requestUID: requestUID, originalMockedHost: originalMockedHost)
  }

  private func isMathing(url: URL, method: String, requestUID: String?, originalMockedHost: String?) -> Bool {
    if let requestUID {
      return self.requestUID == requestUID
    }
    guard method == self.method else { return false }

    let urlTemplate = urlTemplate.withValues(for: .request)

    return matchURL(url.absoluteString, urlTemplate: urlTemplate)
  }

  // swiftlint:disable all
  private func matchURL(_ url: String, urlTemplate: String) -> Bool {
    let templateComponents = urlTemplate.components(separatedBy: "/")
    let urlComponents = url.components(separatedBy: "/")

    guard urlComponents.count == templateComponents.count else {
      return false
    }

    for (index, templateComponent) in templateComponents.enumerated() {
      let urlComponent = urlComponents[index]

      if templateComponent.hasPrefix("{{") && templateComponent.hasSuffix("}}") {
        // Если компонент шаблона находится в фигурных скобках
        let variablePattern = templateComponent.dropFirst(2).dropLast(2)
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
      } else if templateComponent != urlComponent {
        // Если компоненты не совпадают и не являются переменными
        return false
      }
    }

    return true
  }
  // swiftlint:enable all
}
