import Foundation

extension URLSession {

  struct DataResponse {
    let request: URLRequest
    let response: HTTPURLResponse
    let data: Data
    let status: URLResponse.Status
    let fields: [String: String]
  }

  struct RequestAuthorizer {
    typealias Authorizer = (inout URLRequest) async throws -> Void
    private let authorizer: Authorizer

    init(_ authorizer: @escaping Authorizer) {
      self.authorizer = authorizer
    }

    func authorize(_ request: inout URLRequest) async throws {
      try await authorizer(&request)
    }
  }

  struct Config {
    var authorize: Bool = true
    var authorizer: RequestAuthorizer?

    static var `default` = Config()
  }

  private enum InternalError: Error {
    case failedToConvertURLResponseToHTTPURLResponse
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

    guard let response = urlResponse as? HTTPURLResponse else {
      throw InternalError.failedToConvertURLResponseToHTTPURLResponse
    }


    let dataResponse = DataResponse(request: request,
                                    response: response,
                                    data: data,
                                    status: .init(code: response.statusCode),
                                    fields: (response.allHeaderFields as? [String: String]) ?? [:])


    return dataResponse
  }
}

extension URLSession.DataResponse {
  func decode<T: Decodable>(decoder: JSONDecoder = JSONDecoder(), _ type: T.Type = T.self) throws -> T {
    do {
      return try decoder.decode(type, from: data)
    } catch {
      if let callId = request.callID {
        PostMock.shared.decodeError(callID: callId, error: error)
      }
      throw error
    }
  }
}

