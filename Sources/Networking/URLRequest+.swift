import HTTPTypes
import Foundation

extension URLRequest {

  /// Конифгуратор URL запроса
  struct Config {
    /// Схема по умолчанию используется при создании запроса
    public var scheme: String = "https"
    /// Хост по умолчанию ( может содержать префикс пути)
    public var host: String = ""
    /// Путь до вызываемого метода ( должен начинаться со слеша / )
    public var path: String = ""
    /// Параметры которые необходимо передать в URL
    public var urlParams: [String: String] = [:]
    /// Параметры которые необходимо передать в Body запроса
    public var bodyParams: [String: Any] = [:]
    /// Http метод запроса
    public var method: HTTPRequest.Method = .get
    /// Дополнительные заголовоки ( добавляются к заголовкам по умолчанию из HTTPFields.default )
    public var headers = HTTPFields()
    /// The options for writing the parameters as JSON data.
    public var options: JSONSerialization.WritingOptions = [.withoutEscapingSlashes]
    ///  Дефолтный конфиг для создания запроса
    public static var `default` = Config()
  }

  /// Создать запрос с исползование конфига
  static func with(config: Config) -> URLRequest {

    let splitted = splitUrlHost(config.host)
    var components = URLComponents()
    components.host = splitted.host
    components.path = splitted.pathPrefix + config.path
    components.scheme = config.scheme
    if !config.urlParams.isEmpty {
      components.queryItems = config.urlParams.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    guard let url = components.url else {
      fatalError("Вероятно забыли указать слеш в начале path")
    }

    var request = URLRequest(url: url)
    request.httpMethod = config.method.rawValue

    if !config.bodyParams.isEmpty,
       let jsonData = try? JSONSerialization.data(withJSONObject: config.bodyParams, options: config.options) {
      request.httpBody = jsonData
    }

    request.allHTTPHeaderFields = config.headers.headerDictionary

    return request
  }

  /// Создать запрос с исползование настраеваемого конфига
  static func with(
    _ base: Config = .default,
    _ configurate: (inout Config) -> Void
  ) -> URLRequest {
    var config = base
    configurate(&config)
    return with(config: config)
  }
}


private func splitUrlHost(_ inputString: String) -> (host: String, pathPrefix: String) {
    if let range = inputString.range(of: "/") {
        let firstPart = String(inputString[..<range.lowerBound])
        let secondPart = String(inputString[range.upperBound...])
        return (firstPart, "/" + secondPart)
    }
    return (inputString, "")
}


extension [String: Any] {
  mutating func addOptional<T>(_ key: String, value: T?) {
    if let wrapped = value {
      self[key] = wrapped
    }
  }
}
