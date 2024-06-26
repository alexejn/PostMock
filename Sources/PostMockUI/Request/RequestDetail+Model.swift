//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import SwiftUI

final class RequestDetailViewModel: ObservableObject {

  @Published var calls: [HTTPCall] = []
  let item: CollectionItems.Item
  let request: CollectionItems.Request
  private let template: RequestTemplate

  init(item: CollectionItems.Item, request: CollectionItems.Request) {
    self.item = item
    self.request = request
    self.template = request.template(requestUID: item.uid)
    Task { @MainActor in
      self.calls = await HTTPCallStorage.shared.calls(by: template).sorted(by: { $0.start > $1.start })
    }
  }

  func openLink() {
#if os(iOS)
    UIApplication.shared.open(URL.linkToPostman(requestID: item.id))
#endif
  }

}

extension URL {
  static func linkToPostman(requestID: String) -> URL {
    URL(string: "https://postman.co/workspace/\(PostMock.shared.config.workspaceID)/request/\(requestID)")!
  }
}
