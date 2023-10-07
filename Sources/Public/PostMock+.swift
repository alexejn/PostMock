//
//  File.swift
//  
//
//  Created by Alexey Nenastev on 6.10.23..
//

import Foundation

public extension PostMock {
  func decodeError(callID: String, error: Error) {
    guard let uuid = UUID(uuidString: callID) else { return }
    Task {
      await URLRequestCallInfos.shared.dateDecodeError(error, callID: uuid)
    }
  }
}
