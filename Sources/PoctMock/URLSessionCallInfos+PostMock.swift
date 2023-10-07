//
//  HTTPCallInfoDictionary+Postman.swift
//  fbsData
//
//  Created by Alexey Nenastev on 27.8.23..
//  Copyright © 2023 Data Driven Lab. All rights reserved.
//

import Foundation

extension URLRequestCallInfos {
  func calls(by pattern: PostmanRequestPattern) -> [HTTPCallInfo] {

    info.values.filter { info in
      pattern.match(request: info.request)
    }
  }
}
