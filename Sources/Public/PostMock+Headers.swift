//
//  File.swift
//  
//
//  Created by Alexey Nenastev on 6.10.23..
//

import Foundation

public extension PostMock {

  enum Headers {
    /// Хедер используется при обращении к моксерверу в  Postman'е, в этом хедере передается id response который нужно вернуть
    static let xMockResponseId = "x-mock-response-id"
    /// API ключ к постману
    static let xApiKey = "x-api-key"

    /// Id реквеста в постмане
    public static let xRequestId = "x-postmock-request-id"

    public static let xCallId = "x-postmock-call-id"

    public static let xMockedHost = "x-postmock-mocked-host"
  }


  func decodeError(callID: String, error: Error) {
    guard let uuid = UUID(uuidString: callID) else { return }
    Task {
      await URLRequestCallInfos.shared.dateDecodeError(error, callID: uuid)
    }
  }
}

