import XCTest
@testable import PostMockSDK

extension MockResponseID {
  static let mastiff200 = "1122734-8c545657-d643-4db4-b216-d16d699b27fa"
}

struct FactsResponse: Codable {
  let data: [Fact]

  struct Fact: Codable {
    let attributes: Attributes
    struct Attributes: Codable {
      let body: String
    }
  }
}

final class PostMockTests: XCTestCase {

  override func setUp() async throws {
    let config = PostMock.Config(apiKey: "<POSTMAN_API_KEY>",
                                 workspaceID: "05ffed39-33b2-412f-ab4d-b234ad8539b7")

    PostMock.shared.configurate(with: config)

    /// Default MockServer from workspace https://www.postman.com/universal-moon-430028/workspace/postmock
    PostMock.shared.mockServer = MockServer(host: "0997c312-c8ea-435a-8ffd-4a98f4214024.mock.pstmn.io")

    Mock.clearAll()
  }

  func testMock() async throws {
    Mock
      .request("GET", url: "{{host}}/api/v2/facts")
      .with(responseID: .mastiff200)
      .set()

    let request = URL(string: "https://dogapi.dog/api/v2/facts")!

    PostMock.shared.mockIsEnabled = false

    let (data, _) = try await URLSession.shared.data(from: request)
    guard let someFact = try JSONDecoder().decode(FactsResponse.self, from: data).data.first else  {
      throw "Can't get fact"
    }

    XCTAssertFalse(someFact.attributes.body.contains("Mastiff"))

    PostMock.shared.mockIsEnabled = true

    let (data2, _) = try await URLSession.shared.data(from: request)
    guard let mockedFact = try JSONDecoder().decode(FactsResponse.self, from: data2).data.first else  {
      throw "Can't get fact"
    }

    XCTAssertTrue(mockedFact.attributes.body.contains("Mastiff"))
  }
}


extension String: Error {}
