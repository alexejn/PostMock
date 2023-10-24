//
// Created by Alexey Nenastyev on 23.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import XCTest
import PostMock
@testable import Example

final class ExampleTests: XCTestCase {

    override func setUpWithError() throws {
      PostMock.shared.configurate(with: .example)
      PostMock.shared.isEnabled = true
      PostMock.shared.mockIsEnabled = true
      PostMock.shared.mockServer = .default
      PostMock.shared.clearAllMocks()
    }

    func testExample() async throws {
      let vm = ViewModel()

      let mockedName = "BestMock for Random 1 !"

      guard let random = await vm.random1() else { throw "No entry" }

      XCTAssertNotEqual(random.api, mockedName)

      // Mock
      PostMock.Request.random1.mock(with: .bestMock)

      guard let random = await vm.random1() else { throw "No entry" }

      XCTAssertEqual(random.api, mockedName)
    }

}

extension MockServer {
  static var `default` = MockServer(host: "4b74bb04-dd44-47f7-bc97-28a9592d59e8.mock.pstmn.io")
}

extension PostMock.Request {
  static var random1 = Self(requestID: "1122734-94924c70-58df-482a-811d-ff1bb0b03edf")
}

extension MockResponseID {
  static var bestMock = "1122734-205b7fc0-0ab5-44c7-88d1-087b67a54977"
}

extension String: Error {}
