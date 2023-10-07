import HTTPTypes

extension HTTPField.Name {

  enum Postman {
    /// Хедер используется при обращении к моксерверу в  Postman'е, в этом хедере передается id response который нужно вернуть
    static let xMockResponseId = HTTPField.Name("x-mock-response-id")!
    /// API ключ к постману
    static let xApiKey = HTTPField.Name("x-api-key")!
  }

  public enum PostMock {
    /// Id реквеста в постмане
    public static let xRequestId = HTTPField.Name("x-postmock-request-id")!

    public static let xCallId = HTTPField.Name("x-postmock-call-id")!

    public static let xMockedHost = HTTPField.Name("x-postmock-mocked-host")!
  }

}
