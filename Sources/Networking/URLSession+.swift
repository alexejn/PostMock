import HTTPTypes
import HTTPTypesFoundation
import Foundation

extension URLSession {

  public struct DataResponse {
    public let request: URLRequest
    public let response: HTTPResponse
    public let data: Data

    public var status: HTTPResponse.Status { response.status }
    public var fields: HTTPFields { response.headerFields }
  }

  struct RequestAuthorizer {
    public typealias Authorizer = (inout URLRequest) async throws -> Void
    private let authorizer: Authorizer

    init(_ authorizer: @escaping Authorizer) {
      self.authorizer = authorizer
    }

    func authorize(_ request: inout URLRequest) async throws {
      try await authorizer(&request)
    }
  }

  struct Config {
    public var authorize: Bool = true
    public var authorizer: RequestAuthorizer?

    public static var `default` = Config()
  }

  private enum HTTPTypeConversionError: Error {
    case failedToConvertURLResponseToHTTPResponse
  }

  @discardableResult
  static func dataResponse(
    for request: URLRequest,
    base: Config = .default,
    _ configurate: (inout Config) -> Void = { _ in }
  ) async throws -> DataResponse {

    let session = URLSession.shared

    var request = request
    request.setCallId()
    var config = base
    configurate(&config)

    if let authorizer = config.authorizer, config.authorize {
      try await authorizer.authorize(&request)
    }

    let (data, urlResponse) = try await session.data(for: request)

    guard let response = (urlResponse as? HTTPURLResponse)?.httpResponse else {
      throw HTTPTypeConversionError.failedToConvertURLResponseToHTTPResponse
    }


    let dataResponse = DataResponse(request: request,
                                    response: response,
                                    data: data)


    return dataResponse
  }
}

extension URLSession.DataResponse {
  func decode<T: Decodable>(decoder: JSONDecoder = JSONDecoder(), _ type: T.Type = T.self) throws -> T {
    do {
      return try decoder.decode(type, from: data)
    } catch {
      if let callId = request.callID {
        PostMock.shared.decodeError(callID: callId.uuidString, error: error)
      }
      throw error
    }
  }
}

extension HTTPResponse.Status {
  var statusDescription: String {
    reasonPhrase.isEmpty ? HTTPURLResponse.localizedString(forStatusCode: code) : reasonPhrase
  }
}
