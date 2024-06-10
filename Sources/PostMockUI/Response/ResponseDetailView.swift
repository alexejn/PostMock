//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import WebKit

struct ResponseDetailView: View {
  let template: RequestTemplate
  let item: CollectionItems.Item
  let response: CollectionItems.Response
  @State var mock: Mock

  init(template: RequestTemplate,
       item: CollectionItems.Item,
       response: CollectionItems.Response) {
    self.template = template
    self.item = item
    self.response = response

    if let mock = MockStorage.shared.mock(for: template) {
      self.mock = mock
    } else {
      self.mock = Mock(requestTemplate: template,
                       responseID: response.uid,
                       placeholders: [:])
    }
  }

  @EnvironmentObject var model: CollectionsViewModel
  @EnvironmentObject var mocks: MockStorage

  private var isMocked: Bool { mocks.isMocked(requestUID: item.uid,
                                              withResponseID: response.uid) }
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        HStack {
          VStack(alignment: .leading) {
            ResponseLabel(name: response.name)
            Text("\(response.code) \(response.status)")
              .bold()
          }
          Spacer()
          if isMocked {
            Button("UnMock") {
              withAnimation {
                mocks.removeMock(for: template)
              }
            }
            .foregroundColor(.red)
          } else {
            Button("Mock") {
              withAnimation {
                mock.responseID = response.uid
                mocks.set(mock: mock)
              }
            }
            .foregroundColor(.blue)
          }
        }
        .buttonStyle(.plain)

        Divider()
        VStack(alignment: .leading) {
          if isMocked {
            MockByTemplateItemView(template: mock.actualDescription, mocked: isMocked)
          } else {
            MockFormView(mock: $mock)
          }

          Divider()
          MockByHeaderItemView(uid: response.uid, mocked: isMocked)
        }
        .font(.footnote)

        Divider()
      }
      .padding([.top, .horizontal])
      .environment(\.isMocked, isMocked)

      JSONView(json: response.body)
        .edgesIgnoringSafeArea(.all)
    }
  }
}

struct MockFormView: View {

  @Binding var mock: Mock

  var body: some View {
    VStack(alignment: .leading) {
      Text("Mocked if request match template")
        .fontWeight(.light)
      Text(mock.actualDescription)
        .fontWeight(.medium)
        .font(.callout)
        .lineLimit(10)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.leading)

      Spacer()
        .frame(height: 10)
      VStack(alignment: .leading, spacing: 3) {
        ForEach(mock.requestTemplate.urlTemplate.placeholders, id: \.self) { placeholder in
          HStack(alignment: .firstTextBaseline) {
            Text("\(placeholder):")
              .font(.body.monospaced())

            switch mock.placeholders[placeholder] {
            case .environment:
              HStack {
                Text(PostMock.shared.environment[placeholder, .mock] ?? "*")
                clearButton(placeholder: placeholder)
              }
            case .value(let string):
              textField(placeholder: placeholder, value: string)
            default:
              if let environmentValue = PostMock.shared.environment[placeholder, .request] {
                Text(environmentValue)
              } else {
                textField(placeholder: placeholder, value: "")
              }
            }
          }
        }
      }
    }
    .padding(.trailing, 10)
  }

  func clearButton(placeholder: String) -> some View {
    Button(action: {
      mock.placeholders.removeValue(forKey: placeholder)
    }) {
      Image(systemName: "clear")
    }
  }

  func textField(placeholder: String, value: String) -> some View {
    HStack {
      TextField(placeholder, text: .init(get: {
        value
      }, set: { str in
        mock.placeholders[placeholder] = .value(str)
      }))
      .background(Color.gray.opacity(0.1))

      if value.isEmpty == false {
        clearButton(placeholder: placeholder)
      }
    }
  }
}

struct MockByTemplateItemView: View {
  let template: String
  let mocked: Bool

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("Mocked if request match template")
          .fontWeight(.light)
        Text(template)
          .fontWeight(.medium)
          .font(.callout)
          .lineLimit(10)
          .fixedSize(horizontal: false, vertical: true)
          .multilineTextAlignment(.leading)
      }
      Spacer()
      Image(systemName: mocked ? "circle.inset.filled" : "circle")
        .symbolRenderingMode(.palette)
        .foregroundStyle(mocked ? Color.blue :  Color.gray)
        .opacity(!PostMock.shared.mockIsEnabled ? 0.3 : 1)
        .frame(width: 10)
    }
  }
}

struct MockByHeaderItemView: View {
  let uid: String
  let mocked: Bool

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("Mocked if header **\(PostMock.Headers.xPostmanRequestId)** equals to:")
          .fontWeight(.light)
        HStack {
          Text(uid)
            .fontWeight(.thin)
            .font(.footnote)
            .lineLimit(1)
            .truncationMode(.head)


          Button(action: {
            UIPasteboard.general.string = uid
          }) {
            Image(systemName: "doc.on.doc")
          }
        }
      }
      Spacer()
      Image(systemName: mocked ? "circle.inset.filled" : "circle")
        .symbolRenderingMode(.palette)
        .foregroundStyle(mocked ? Color.blue :  Color.gray)
        .opacity(!PostMock.shared.mockIsEnabled ? 0.3 : 1)
        .frame(width: 10)
    }
  }
}

struct ResponseDetailView_Previews: PreviewProvider {
  static let req = CollectionItems.Item.authorize

  static let model = CollectionsViewModel(.sample)
  static let mocks = MockStorage.shared

  static var previews: some View {
    Text("Demo")
      .sheet(isPresented: .constant(true)) {
        ResponseDetailView(template: req.requestTemplate!,
                           item: req,
                           response: req.response!.first!)
          .environmentObject(model)
          .environmentObject(mocks)
          .environmentObject(PostMock.shared)
      }
      .onAppear {
        PostMock.shared.environment.set(value: "http://google.com",
                                        scope: .request,
                                        for: "host")
      }
  }
}
