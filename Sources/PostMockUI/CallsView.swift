import SwiftUI

private struct CallsViewItem: View {

  let call: HTTPCallInfo

  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .firstTextBaseline) {
        Text(Date(timeIntervalSince1970: call.start).formatted(format: .DateFormat.hhMMss))
          .font(.caption)
          .bold()
          .opacity(0.5)
        Text(call.method)
          .foregroundColor(call.method.methodColor)
        Divider()
          .frame(height: 10)
        Text(call.host)
          .font(.caption2)
          .fontWeight(.thin)
          .lineLimit(1)
        Spacer()
        if call.decodeError != nil {
          Image(systemName: "exclamationmark.transmission")
            .foregroundColor(.red)
        }

        if let duration = call.duration {
          Divider()
            .frame(height: 10)
          Text("\(duration.formatted(maximumFractionDigits: 2)) s")
            .fontWeight(.light)
        }
        Divider()
          .frame(height: 10)
        if let status = call.status {
          Text("\(status.code)")
            .foregroundColor(status.statsuColor)
        }
      }
      .font(.footnote)
      Text(call.path)
        .multilineTextAlignment(.leading)
        .font(.footnote)
        .foregroundColor(call.host.isMockServerHost ? .blue : .black)
    }
    .foregroundColor(.black)
  }
}

struct CallsView: View {

  @State var calls: [HTTPCallInfo] = []

  private let dictionary = URLRequestCallInfos.shared


  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        ForEach(calls, id: \.callID) { call in
          NavigationLink {
            CallDetailView(call: call)
          } label: {
            CallsViewItem(call: call)
          }
          Divider()
            .padding(.vertical, 2)
        }
      }
      .padding(.horizontal)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Clear", action: {
          Task {
            await dictionary.clear()
          }
        })
      }
    }
    .onAppear {
      Task { @MainActor in
        let values = await dictionary.info.values
        self.calls = Array(values).sorted(by: { $0.start > $1.start })
      }
    }
    .navigationTitle("Calls")
  }
}

extension Double {
  func formatted(maximumFractionDigits: Int) -> String {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = maximumFractionDigits
    return formatter.string(from: NSNumber(value: self)) ?? ""
  }
}

extension Date {
  func formatted(format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
}

extension String {
  enum DateFormat {
    static let hhMMss: String = "HH:mm:ss"
  }
}

struct CallsView_Previews: PreviewProvider {
  static var previews: some View {

    NavigationView {
      CallsView()
    }
  }
}
