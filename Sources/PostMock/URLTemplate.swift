//
// Created by Alexey Nenastyev on 5.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

struct URLTemplate: Codable, Hashable {
  let url: String
  let placeholders: [String]

  init(url: String){
    self.url = url
    self.placeholders = URLTemplate.extractExtededPlaceholderKeys(from: url)
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

  private static func extractExtededPlaceholderKeys(from urlString: String) -> [String] {
      // Регулярное выражение для поиска плейсхолдеров в формате {{key}} и :key
      let regexPattern = "\\{\\{(.*?)\\}\\}|:(\\w+)"

      // Компиляция регулярного выражения
      guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
          return []
      }

      // Поиск совпадений в строке URL
      let matches = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count))

      // Извлечение ключей плейсхолдеров из совпадений
      let keys = matches.compactMap { match -> String? in
          // Проверка, есть ли две группы захвата (одна для {{key}}, другая для :key)
          if let range1 = Range(match.range(at: 1), in: urlString) {
              return String(urlString[range1])
          } else if let range2 = Range(match.range(at: 2), in: urlString) {
              return String(urlString[range2])
          }
          return nil
      }

      return keys
  }
}
