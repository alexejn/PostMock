//
// Created by Alexey Nenastyev on 22.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

struct CallBodyView: View {

  private let bodyString: String?

  init(bodyData: Data?) {
    self.bodyString = bodyData?.prettyPrintedJSONString
  }

  init(string: String) {
    self.bodyString = string
  }

  var body: some View {
    Group {
      if let bodyString = bodyString {
        let lines = bodyString.split(whereSeparator: \.isNewline)
        ScrollView {
          HStack {
            LazyVStack(alignment: .leading) {
              ForEach(lines.indices, id: \.self) { index in
                Text(lines[index])
              }
            }
            Spacer()
          }
        }
        .font(.footnote)
        .padding(.horizontal, 8)
      } else {
        EmptyView()
      }
    }
  }
}

struct CallBodyView_Previews: PreviewProvider {
  static var previews: some View {
    CallBodyView(string: "asdsd")
  }
}
