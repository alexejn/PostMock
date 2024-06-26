//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import Foundation

private struct HeadersView: View {
  var headers: [String: String]?

  private let gridItemLayout = [GridItem(.flexible(minimum: 0, maximum: 150), alignment: .topTrailing),
                                GridItem(.flexible(), alignment: .topLeading)]


  init(headers: [String : String]?) {
    self.headers = headers
  }

  var body: some View {
    if let headers = headers {
      ScrollView {
        LazyVGrid(columns: gridItemLayout, spacing: 5) {
          ForEach(Array(headers.keys), id: \.self) { key in
            Text(key)
              .font(.footnote)
              .padding(2)
              .background(Color.gray.opacity(0.1))
            Text(headers[key]!)
              .padding(2)
              .background(Color.gray.opacity(0.1))
          }
        }
        .padding(.horizontal, 8)
      }
    } else {
      EmptyView()
    }
  }
}

struct CallDetailView: View {

  let call: HTTPCall

  @State var selected: Int = 1

  var body: some View {
    TabView(selection: $selected)  {
      if let decodeError = call.decodeError {
        CallBodyView(string: "\(decodeError)")
          .tag(0)
          .tabItem {
            Label("Issue", systemImage: "exclamationmark.transmission")
              .foregroundColor(.red)
          }
      }

      CallBodyView(bodyData: call.data)
        .navigationTitle("Response Body")
        .tag(1)
        .tabItem {
          Label("Response", systemImage: "airplane.arrival")
        }

      CallBodyView(bodyData: call.request.httpBody)
        .navigationTitle("Request Body")
        .tag(2)
        .tabItem {
          Label("Request", systemImage: "airplane.departure")
        }

      HeadersView(headers: call.responseHeader)
        .navigationTitle("Response Headers")
        .tag(3)
        .tabItem {
          Label("Response", systemImage: "list.dash.header.rectangle")
        }

      HeadersView(headers: call.request.allHTTPHeaderFields)
        .navigationTitle("Request Headers")
        .tag(4)
        .tabItem {
          Label("Request", systemImage: "list.dash.header.rectangle")
        }
    }
    .navigationTitle(call.status?.statusDescription ?? "")
    .navigationBarTitleDisplayMode(.inline)

  }
}

struct CallDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CallDetailView(call: HTTPCall(callID: UUID(),
                                        request: .init(url: .linkToPostman(requestID: "1"))))
    }
  }
}

extension Data {
  var prettyPrintedJSONString: String? { /// NSString gives us a nice sanitized debugDescription
    guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
          let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
          let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

    return prettyPrintedString as String?
  }
}
