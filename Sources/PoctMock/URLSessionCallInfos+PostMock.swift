//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

extension URLRequestCallInfos {
  func calls(by pattern: PostmanRequestPattern) -> [HTTPCallInfo] {

    info.values.filter { info in
      pattern.match(request: info.request)
    }
  }
}
