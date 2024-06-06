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
  public var actualDescription: String { "\(method.uppercased()) \(urlTemplateWithValues())" }

  public init(method: String, url: String, requestUID: String) {
    self.method = method
    self.urlTemplate = URLTemplate(url: url)
    self.requestUID = requestUID
  }

  private func urlTemplateWithValues() -> String {
    guard urlTemplate.placeholders.isEmpty == false else { return urlTemplate.url }

    var string = urlTemplate.url
    for placeholder in urlTemplate.placeholders {
      guard let value = PostMock.shared.environment[placeholder, .request] else { continue }
      string.replacedPlaceholder(placeholder, with: value)
    }
    return string
  }

  public func isMathing(request: URLRequest) -> Bool {
    guard var url = request.url,
          let method = request.httpMethod  else { return false }

    if let requestUID = request.value(forHTTPHeaderField: PostMock.Headers.xPostmanRequestId) {
      return self.requestUID == requestUID
    }

    if let mockedHost = request.value(forHTTPHeaderField:PostMock.Headers.xMockedHost), let host = url.host {
      url = URL(string: url.absoluteString.replacingOccurrences(of: host, with: mockedHost))!
    }

    guard method == self.method else { return false }

    var urlTemplate = urlTemplateWithValues()
    urlTemplate.appendSchemeIfDontHave(scheme: url.scheme)

    let result = String.matchComponents(url: url.absoluteString, 
                                        template: urlTemplate)

    return result
  }
}
