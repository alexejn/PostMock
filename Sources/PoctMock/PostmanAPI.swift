//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

private extension URLRequest.Config {
  static var postman: Self  {
    var config = Self.default
    config.host = "api.getpostman.com"
    config.headers[PostMock.Headers.xApiKey] = PostMock.shared.config.apiKey
    config.headers[PostMock.Headers.xExclude] = ""
    return config
  }
}

struct PostmanAPI {

  enum Errors: Error {
    case noMockServers
  }

  static func collectionItems(collectionID: String) async throws -> CollectionItems {
    let request = URLRequest.with(.postman) {
      $0.method = .get
      $0.path = "/collections/\(collectionID)"
    }

    let resp = try await URLSession.dataResponse(for: request)

    return try resp.decode(CollectionReponse.self).collection
  }

  static func workspace(worspaceID: String) async throws -> Workspace {
    let request = URLRequest.with(.postman) { config in
      config.method = .get
      config.path = "/workspaces/\(worspaceID)"
    }
   

    let resp = try await URLSession.dataResponse(for: request)

    return try resp.decode(WorkspaceResponse.self).workspace
  }

  static func mocks(workspaceID: String) async throws -> [MockServer] {

    let request = URLRequest.with(.postman) { config in
      config.method = .get
      config.path = "/mocks"
      config.urlParams["workspace"] = workspaceID

    }

    let resp = try await URLSession.dataResponse(for: request)

    let mocks = try resp.decode(MocksResponse.self).mocks.map {
      return MockServer(id: $0.id, name: $0.name, host: $0.mockUrl.host!, collectionUID: $0.collection)
    }
    return mocks
  }
}

typealias CollectionItems = CollectionReponse.Collection

struct Workspace: Codable, Equatable  {

  struct Collection: Codable, Hashable {
    let id: String
    let uid: String
    let name: String
  }

  struct Mock: Codable, Identifiable, Hashable {
    let id: String
    let name: String
  }

  let name: String
  let collections: [Collection]?
  let mocks: [Mock]?
}

struct WorkspaceResponse: Decodable {
  let workspace: Workspace
}

struct MocksResponse: Decodable {
  let mocks: [Mock]

  struct Mock: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let uid: String
    let collection: String
    let mockUrl: URL
  }
}

struct CollectionReponse: Decodable {
  struct Collection: Codable {
    let item: [Item]

    struct Item: Codable, Identifiable {
      var id: String { uid }
      let name: String
      let item: [Item]?
      let uid: String
      let request: Request?
      let response: [Response]?

      var reponseNames: [String] {
        response?.map { $0.name } ?? []
      }

      var requestTemplate: RequestTemplate? {
        request?.template(requestUID: uid)
      }
    }

    struct Response: Codable, Identifiable {
      var id: String { uid }
      let uid: String
      let name: String
      let status: String
      let code: Int
      let body: String


      enum CodingKeys: String, CodingKey {
        case uid
        case name
        case status
        case code
        case body
      }

      init(uid: String, name: String, status: String, code: Int, body: String) {
        self.uid = uid
        self.name = name
        self.status = status
        self.code = code
        self.body = body
      }

      init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try values.decode(String.self, forKey: .uid)
        self.name =  values.decode(key: .name, or: "")
        self.status =  values.decode(key: .status, or: "")
        self.code =  values.decode(key: .code, or: 0)
        self.body =  values.decode(key: .body, or: "")
      }
    }

    struct Request: Codable {
      let method: String
      let url: RequestURL

      enum CodingKeys: String, CodingKey {
        case method
        case url
      }

      init(method: String, url: RequestURL) {
        self.method = method
        self.url = url
      }

      init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.method = try values.decode(String.self, forKey: .method)
        let url = try? values.decodeIfPresent(RequestURL.self, forKey: .url)
        self.url = url ?? .empty
      }

      func template(requestUID: String) -> RequestTemplate {
        .init(method: method,
              url: url.raw,
              requestUID: requestUID)
      }
    }

    struct RequestURL: Codable, CustomStringConvertible {
      let raw: String
      let host: [String]
      var path: [String] = []
      var description: String {
        (host.first ?? "") + "/" + path.joined(separator: "/")
      }

      static var empty = RequestURL(raw: "", host: [])
    }
  }

  let collection: Collection
}
