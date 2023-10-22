//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

extension CollectionItems {
  static var sample: Self {
    Self(item: [
      .folder("Auth", items: .authorize, .createCollection)
    ])
  }
}

extension CollectionItems.Item {
  static func folder(_ name: String, items: Self...) -> Self {
    Self(name: name, item: items, uid: name, request: nil, response: nil)
  }

  static func request(_ name: String, method: String, url: String, uid: String? = nil, responses: CollectionItems.Response...) -> Self {
    Self(name: name,
         item: nil,
         uid: uid ?? name,
         request: .init(method: method,
                        url: .init(raw: url, host: ["{{host}}"])),
         response: responses)
  }

  static var authorize: Self {
    .request("v1/oath/authorize",
             method: "get",
             url: "/v1/oauth/authorize",
             uid: "1122734-5cff63c7-7fbc-43e1-857a-09f652ef2812",
             responses: .sample(reqID: "1122734-ffff63c7-7fbc-43e1-857a-09f652ef2812", name: "200: Code"))
  }

  static var createCollection: Self {
    .request("Create collection",
             method: "post",
             url: "/v5/oauth/authorize",
             uid: "1122734-5cff63c7-7fbc-43e1-857a-09f652ef281b",
             responses: .sample(reqID: "Create collection",
                                name: "200: Code"))
  }


}

extension CollectionItems.Response {
  static func sample(reqID: String, name: String) -> Self {
    .init(uid: reqID,
          name: name, status: "OK", code: 200, body: "{\n    \"code\": \"asdsadadssdsds\",\n    \"state\": \"\"\n}")
  }
}


extension Workspace.Collection {
  static var sample = Self(id: "", uid: "", name: "Sample Collection")
}
