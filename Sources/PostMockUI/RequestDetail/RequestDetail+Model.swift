import Foundation
import SwiftUI

final class RequestDetailViewModel: ObservableObject {

  @Published var calls: [HTTPCallInfo] = []
  let item: CollectionItems.Item
  let request: CollectionItems.Request
  private let pattern: PostmanRequestPattern

  init(item: CollectionItems.Item, request: CollectionItems.Request) {
    self.item = item
    self.request = request
    self.pattern = request.pattern(requestUID: item.uid)
    Task { @MainActor in
      self.calls = await URLRequestCallInfos.shared.calls(by: pattern).sorted(by: { $0.start > $1.start })
    }
  }

  func openLink() {
    UIApplication.shared.open(URL.linkToPostman(requestID: item.id))
  }

  func copyToClipboard() {
    UIPasteboard.general.string = item.uid
  }
}

extension URL {
  static func linkToPostman(requestID: String) -> URL {
    URL(string: "https://postman.co/workspace/\(PostMock.shared.config.workspaceID)/request/\(requestID)")!
  }
}
