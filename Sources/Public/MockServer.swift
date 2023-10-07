public struct MockServer: Codable, Hashable, Identifiable {
  public let id: String
  public let name: String
  public let host: String
  public let collection: String

  public init(id: String, name: String, host: String, collection: String) {
    self.name = name
    self.host = host
    self.id = id 
    self.collection = collection
  }
}
