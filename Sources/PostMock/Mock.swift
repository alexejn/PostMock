//
// Created by Alexey Nenastyev on 6.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public typealias MockResponseID = String

public struct Mock: Codable {
  public typealias Placeholders = [String: PlaceholderValue]

  public enum PlaceholderValue: Codable {
    case environment
    case value(String)
  }

  public let requestTemplate: RequestTemplate
  public var responseID: MockResponseID
  public var placeholders: Placeholders

  public var actualDescription: String { "\(urlTemplateWithValues())" }

  
  private func urlTemplateWithValues() -> String {
    let placeholders = requestTemplate.urlTemplate.placeholders
    let url = requestTemplate.urlTemplate.url

    guard placeholders.isEmpty == false else { return url }

    var string = url
    for placeholder in placeholders {
      if let value = PostMock.shared.environment[placeholder, .request] {
        string.replacedPlaceholder(placeholder, with: value)
      } else if let kind = self.placeholders[placeholder] {
        switch kind {
          case .environment:
            guard let value = PostMock.shared.environment[placeholder, .mock] else { continue }
            string.replacedPlaceholder(placeholder, with: value)
          case .value(let value):
            guard value.isEmpty == false else { continue }
            string.replacedPlaceholder(placeholder, with: value)
        }
      }
    }

    return string
  }


  public func isMathing(request: URLRequest) -> Bool {
    guard let url = request.url,
          let method = request.httpMethod  else { return false }

    let requestUID = request.value(forHTTPHeaderField: PostMock.Headers.xPostmanRequestId)

    // Different request
    guard requestUID == nil || requestUID == requestTemplate.requestUID else { return false }
    // Already mocked
    guard request.value(forHTTPHeaderField:PostMock.Headers.xMockedHost) == nil else { return false }

    guard method == requestTemplate.method else { return false }

    var urlTemplate = urlTemplateWithValues()
    urlTemplate.appendSchemeIfDontHave(scheme: url.scheme)

    let result = String.matchComponents(url: url.absoluteString,
                                        template: urlTemplate)

    return result
  }
}
