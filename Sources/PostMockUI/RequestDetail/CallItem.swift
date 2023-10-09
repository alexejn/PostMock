//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI

struct CallItem: View {

  let call: HTTPCallInfo

  var body: some View {

    VStack(alignment: .leading) {
      HStack(alignment: .firstTextBaseline) {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Text(call.startString)
            .font(.caption)
            .bold()
          if #available(iOS 15.0, *) {
            Text(".\(Date(timeIntervalSince1970: call.start), format: .dateTime.secondFraction(.fractional(3)))")
              .font(.caption)
              .fontWeight(.thin)
          }
        }

        Divider().frame(height: 14)
        Text(call.host)
          .font(.caption2)
          .fontWeight(.thin)

        Divider().frame(height: 14)
        Spacer()
        Text(call.statusString)
          .foregroundColor(call.status?.statsuColor ?? Color.black)
          .font(.caption2)
          .fontWeight(.bold)

      }.lineLimit(1)

      Text(call.path)
        .multilineTextAlignment(.leading)
        .font(.callout.monospacedIOS14())
        .padding(.vertical, 8)
        .foregroundColor(call.host.isMockServerHost ? .blue : .black)

      Divider()
      HStack(alignment: .center) {

        if #available(iOS 15.0, *), let duration = call.duration {
          Text("\(duration, format: .number.precision(.fractionLength(3))) sec")
            .font(.title3)
            .fontWeight(.light)
          Divider().frame(height: 20)
        }
//        if let size = viewData.size {
//          Text("\(size) byte")
//            .font(.title3)
//            .fontWeight(.thin)
//          Divider().frame(height: 20)
//        }
        Spacer()

        if call.decodeError != nil {
          Text("Decode Issue")
            .font(.caption2)
            .foregroundColor(.red)
        }

      }.lineLimit(1)
        .font(.subheadline)
    }
    .padding()
    .background(call.status?.statsuColor.opacity(0.08) ?? Color.black)
    .foregroundColor(.black)

  }
}

extension URLResponse.Status {
  var statsuColor: Color {
    switch kind {
    case .successful: return .green
    case .invalid: return .orange
    case .clientError: return .red
    case .serverError: return .brownIOS14
    default: return .black
    }
  }
}

extension String {
  var isMockServerHost: Bool {
    hasSuffix("mock.pstmn.io")
  }
}

extension Color {
  static var brownIOS14: Color {
    if #available(iOS 15.0, *) {
      return  .brown
    } else {
      return .purple
    }
  }
}

extension Font {
  func monospacedIOS14() -> Font {
    if #available(iOS 15.0, *) {
      return  self.monospaced()
    }
    return self
  }
}

struct CallItem_Previews: PreviewProvider {

  static var previews: some View {
    VStack {
      CallItem(call: .google)
    }
  }
}

extension HTTPCallInfo {

  var hostString: String {
    guard let host = request.url?.host else { return "" }
    return "\(host)"
  }

  var pathString: String {
    guard let relativePath = request.url?.path else { return "" }
    if let query = request.url?.query {
      return "\(relativePath)?\n\(query)"
    }
    return "\(relativePath)"
  }

  var durationString: String {
    guard let duration = duration else { return "" }
    return duration.formatted(maximumFractionDigits: 2)
  }

  var startString: String {
    Date(timeIntervalSince1970: start).formatted(format: .DateFormat.hhMMss)
  }

  var statusString: String {
    guard let status = status else { return "" }
    return "\(status.code) \(status.statusDescription)"
  }
}

extension URLRequest {
  static var sample = URLRequest.with {
    $0.host = "google.com"
    $0.path = "/postmock"
    $0.method = .get
  }
}

extension HTTPCallInfo {

  static var google = HTTPCallInfo(callID: UUID(),
                                    request: .sample)
}
