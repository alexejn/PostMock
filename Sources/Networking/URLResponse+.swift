//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

extension URLResponse {
  struct Status {
    let code: Int

    /// The first digit of the status code defines the kind of response.
    enum Kind {
        /// The status code is outside the range of 100...599.
        case invalid
        /// The status code is informational (1xx) and the response is not final.
        case informational
        /// The status code is successful (2xx).
        case successful
        /// The status code is a redirection (3xx).
        case redirection
        /// The status code is a client error (4xx).
        case clientError
        /// The status code is a server error (5xx).
        case serverError
    }

    var kind: Kind {
        switch self.code {
        case 100 ... 199:
            return .informational
        case 200 ... 299:
            return .successful
        case 300 ... 399:
            return .redirection
        case 400 ... 499:
            return .clientError
        case 500 ... 599:
            return .serverError
        default:
            return .invalid
        }
    }

    var statusDescription: String { HTTPURLResponse.localizedString(forStatusCode: code) }
  }
}
