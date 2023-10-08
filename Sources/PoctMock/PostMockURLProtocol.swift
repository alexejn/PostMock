import Foundation

open class PostMockURLProtocol: URLProtocol {
  static let internalKey = "com.postmock.internal"
  static let callId = "com.postmock.callID"

  private var info: HTTPCallInfo?
  private var response: URLResponse?
  private var responseData: NSMutableData?

  private lazy var session: URLSession = { [unowned self] in
    return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
  }()

  public override class func canInit(with request: URLRequest) -> Bool {
    return canServeRequest(request)
  }

  open override class func canInit(with task: URLSessionTask) -> Bool {
    if #available(iOS 13.0, macOS 10.15, *) {
      if task is URLSessionWebSocketTask {
        return false
      }
    }

    guard let request = task.currentRequest else { return false }
    return canServeRequest(request)
  }

  private class func canServeRequest(_ request: URLRequest) -> Bool {
    guard PostMock.shared.isEnabled else { return false }

    guard URLProtocol.property(forKey: PostMockURLProtocol.internalKey, in: request) == nil,
          let url = request.url,
          (url.absoluteString.hasPrefix("http") || url.absoluteString.hasPrefix("https")) else {
      return false
    }

    return true
  }

  override public func startLoading() {
    let callId = request.callID?.uuid ?? UUID()
    info = .init(callID: callId, request: request)

    let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
    URLProtocol.setProperty(true, forKey: PostMockURLProtocol.internalKey, in: mutableRequest)
    session.dataTask(with: mutableRequest as URLRequest).resume()
  }

  override public func stopLoading() {
    session.getTasksWithCompletionHandler { dataTasks, _, _ in
      dataTasks.forEach { $0.cancel() }
      self.session.invalidateAndCancel()
    }
  }

  public override final class func canonicalRequest(for request: URLRequest) -> URLRequest {
    var mutated = request
    mutated.mockIfNeed()
    return mutated
  }
}

private extension String {
  var uuid: UUID? { UUID(uuidString: self) }
}


extension PostMockURLProtocol: URLSessionDataDelegate {

  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    responseData?.append(data)
    client?.urlProtocol(self, didLoad: data)
  }

  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    self.response = response
    responseData = NSMutableData()

    let cachePolicy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: cachePolicy)
    completionHandler(.allow)
  }

  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    defer {
      if let error = error {
        client?.urlProtocol(self, didFailWithError: error)
      } else {
        client?.urlProtocolDidFinishLoading(self)
      }
    }

    guard task.originalRequest != nil else {
      return
    }

    if error != nil {
      info?.error = error
    } else if let response = response {
      let data = (responseData ?? NSMutableData()) as Data
      info?.response = response
      info?.data = data
    }
    info?.end = CFAbsoluteTimeGetCurrent()

    if let info = info {
      Task {
        await URLRequestCallInfos.shared.set(info)
      }
    }

  }

  public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
    let updatedRequest: URLRequest
    if URLProtocol.property(forKey: PostMockURLProtocol.internalKey, in: request) != nil {
      let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
      URLProtocol.removeProperty(forKey: PostMockURLProtocol.internalKey, in: mutableRequest)

      updatedRequest = mutableRequest as URLRequest
    } else {
      updatedRequest = request
    }

    client?.urlProtocol(self, wasRedirectedTo: updatedRequest, redirectResponse: response)
    completionHandler(updatedRequest)
  }


  public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

    let challengeHandler = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: PostMockAuthenticationChallengeSender(handler: completionHandler))
    client?.urlProtocol(self, didReceive: challengeHandler)
  }

#if !os(OSX)
  public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    client?.urlProtocolDidFinishLoading(self)
  }
#endif
}

class PostMockAuthenticationChallengeSender : NSObject, URLAuthenticationChallengeSender {

  typealias PostMockAuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

  let handler: PostMockAuthenticationChallengeHandler

  init(handler: @escaping PostMockAuthenticationChallengeHandler) {
    self.handler = handler
    super.init()
  }

  func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
    handler(.useCredential, credential)
  }

  func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
    handler(.useCredential, nil)
  }

  func cancel(_ challenge: URLAuthenticationChallenge) {
    handler(.cancelAuthenticationChallenge, nil)
  }

  func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
    handler(.performDefaultHandling, nil)
  }

  func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
    handler(.rejectProtectionSpace, nil)
  }
}
