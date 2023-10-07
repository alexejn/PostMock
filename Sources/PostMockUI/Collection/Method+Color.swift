//
//  File.swift
//
//
//  Created by Alexey Nenastev on 4.10.23..
//

import SwiftUI

extension String {
  var methodColor: Color {
    switch self.lowercased() {
    case "get":
      return Color(hex: 0x89DA9f)
    case "post":
      return Color(hex: 0xFFEB90)
    case "del", "delete":
      return Color(hex: 0xF2A397)
    case "put":
      return Color(hex: 0x84B0F5)
    case "patch":
      return Color(hex: 0xB7A5D7)
    case "head":
      return Color(hex: 0x89DA9f)
    case "options":
      return Color(hex: 0xE068AD)
    default:
      return Color.black
    }
  }
}

extension Color {
  init(hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xff) / 255,
      green: Double((hex >> 08) & 0xff) / 255,
      blue: Double((hex >> 00) & 0xff) / 255,
      opacity: alpha
    )
  }
}
