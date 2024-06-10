//
// Created by Alexey Nenastyev on 6.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

extension String {
  mutating func replacedPlaceholder(_ name: String, with value: String) {
    self = replacingOccurrences(of: "{{\(name)}}", with: value)
    self = replacingOccurrences(of: ":\(name)", with: value)
  }

  mutating func appendSchemeIfDontHave(scheme: String?) {
    guard let scheme, !lowercased().hasPrefix("http") else { return }
    self = "\(scheme)://\(self)"
  }

  // swiftlint:disable all
  static func matchComponents(url: String, template: String) -> Bool {
    let templateComponents = template.components(separatedBy: "/")
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
      } else if templateComponent.first == ":" {
        // Компонент является Path Variables
        return true
      } else if templateComponent != urlComponent {
        // Если компоненты не совпадают и не являются переменными
        return false
      }
    }
    return true
  }
  // swiftlint:enable all
}
