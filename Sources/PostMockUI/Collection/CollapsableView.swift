
import SwiftUI

struct CollapsableView<Label: View, Content: View>: View {
  @AppStorage  private var isCollapsed: Bool
  @ViewBuilder private var label: () -> Label
  @ViewBuilder private var content: () -> Content

  @Environment(\.isMocked) var isMocked

  init(id: String,
       @ViewBuilder label: @escaping () -> Label,
       @ViewBuilder content: @escaping () -> Content) {

    self.label = label
    self.content = content
    self._isCollapsed = AppStorage(wrappedValue: true, "collapes.\(id)")
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .firstTextBaseline, spacing: 10) {
        Button(action: {
          withAnimation {
            isCollapsed.toggle()
          }
        },
               label: {
          Image(systemName: "chevron.right")
            .rotationEffect(.degrees(isCollapsed ? 0 : 90))
            .frame(width: 20, height: 20)
            .foregroundColor(isMocked ? .blue : .gray)
            .font(.body.weight(isMocked ? .medium : .regular))
        })
        label()
        Spacer()
      }
      if !isCollapsed {
        content()
          .padding(.leading, 15)
      }
    }
    .animation(.easeInOut, value: isCollapsed)
  }
}

struct CollapsableView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(alignment: .leading, spacing: 10, content: {
      CollapsableView(id: "1") {
        Text("HEADER")
      } content: {
       Text("Item 1")
       Text("Item 2")
       Text("Item 3")
      }

      CollapsableView(id: "2") {
        Text("HEADER 2")
      } content: {
       Text("Item 1")
       Text("Item 2")
       Text("Item 3")
      }
      .environment(\.isMocked, true)
    })
    .padding()
  }
}
