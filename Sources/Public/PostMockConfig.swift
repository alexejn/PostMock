import Foundation

public struct PostMockConfig: Equatable  {
  public var apiKey: String
  public var workspaceID: String
  public var defaultCollectionID: String?
  public var defaultMockServerID: String?

  public init(apiKey: String, 
              workspaceID: String,
              defaultCollectionID: String? = nil,
              defaultMockServerID: String? = nil) {
    self.apiKey = apiKey
    self.workspaceID = workspaceID
    self.defaultCollectionID = defaultCollectionID
    self.defaultMockServerID = defaultMockServerID
  }

  static var empty = PostMockConfig(apiKey: "", workspaceID: "")
  static var test = PostMockConfig(apiKey: "PMAK-64e7229e199aef003fe44a9b-0e9b2291c24ef3bf41ae44685b2a456987",
                                   workspaceID: "8db41546-1957-4f2e-b96a-2e9a6e7be379",
                                   defaultCollectionID: "29158833-9a5119bf-a9cd-468d-a4ec-cad8c5a028b4")
}
