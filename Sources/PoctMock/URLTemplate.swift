//
// Created by Alexey Nenastyev on 5.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

struct URLTemplate: Codable, Hashable {
  let url: String
  let placeholders: [String]

  init(url: String){
    self.url = url
    self.placeholders = URLTemplate.extractPlaceholderKeys(from: url)
  }

  private static func extractPlaceholderKeys(from urlString: String) -> [String] {
      // Регулярное выражение для поиска плейсхолдеров в формате {{key}}
      let regexPattern = "\\{\\{(.*?)\\}\\}"

      // Компиляция регулярного выражения
      guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
          return []
      }

      // Поиск совпадений в строке URL
      let matches = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count))

      // Извлечение ключей плейсхолдеров из совпадений
      let keys = matches.compactMap { match -> String? in
          guard match.numberOfRanges == 2 else {
              return nil
          }

          if let range = Range(match.range(at: 1), in: urlString) {
              return String(urlString[range])
          }

          return nil
      }

      return keys
  }

  func withValues(for scope: PostMockEnvironment.Scope) -> String {
    guard placeholders.isEmpty == false else { return url }

    var string = url
    for placeholder in placeholders {
      guard let value = PostMock.shared.environment[placeholder, scope] else { continue }
      string = string.replacingOccurrences(of: "{{\(placeholder)}}", with: value)
    }

    return string
  }
}
