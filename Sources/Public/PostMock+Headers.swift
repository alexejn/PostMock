//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

public extension PostMock {

  enum Headers {
    /// Хедер используется при обращении к моксерверу в  Postman'е, в этом хедере передается id response который нужно вернуть
    static let xMockResponseId = "x-mock-response-id"
    /// API ключ к постману
    static let xApiKey = "x-api-key"

    /// Id реквеста в постмане
    public static let xPostmanRequestId = "x-postmock-request-id"

    public static let xCallId = "x-postmock-call-id"

    public static let xMockedHost = "x-postmock-mocked-host"

    public static let xExclude = "x-postmock-exclude"
  }


  func decodeError(callID: String, error: Error) {
    guard let uuid = UUID(uuidString: callID) else { return }
    Task {
      await HTTPCallStorage.shared.dateDecodeError(error, callID: uuid)
    }
  }
}

