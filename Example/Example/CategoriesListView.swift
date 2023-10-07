//
//  FreeAPIView.swift
//  Example
//
//  Created by Alexey Nenastev on 4.10.23..
//

import SwiftUI
import HTTPTypes
import PostMock

struct CategoryView: View {
  let category: String
  @ObservedObject var model: ViewModel

  var body: some View {
    Group {
      if model.isLoading {
        ProgressView()
      } else {
        List(model.entries, id: \.self) { entry in
          EntryView(entry: entry)
        }
      }
    }
    .task {
      await model.loadEntries(category: category)
    }
  }
}

struct EntryView: View {
  let entry: Entry

  var body: some View {
    VStack(alignment: .leading) {
      Text(entry.api).font(.headline)
      Text(entry.description).font(.subheadline)
      Link(destination: URL(string: entry.link)!, label: {
        Text(entry.link).font(.footnote.monospaced())
      })
    }
  }
}

struct CategoriesListView: View {
  @StateObject var model = ViewModel()
  @State var postMockViewPresented: Bool = false

  var body: some View {
    NavigationStack {
      Group {
        if model.isLoading {
          ProgressView()
        } else {
          List(model.categories, id: \.self) { category in
            NavigationLink {
              CategoryView(category: category, model: model)
            } label: {
              Text(category)
            }
          }
        }
      }
      .navigationTitle("Select a category")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Random1") {
            Task {
              await model.random1()
            }
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button("Random2") {
            Task {
              await model.random2()
            }
          }
        }

        ToolbarItem(placement: .topBarLeading) {
          Button("PostMock") {
            postMockViewPresented.toggle()
          }
        }
      }
      .sheet(item: $model.random) { entry in
        EntryView(entry: entry)
          .padding()
          .presentationDetents([.medium])
      }
      .sheet(isPresented: $postMockViewPresented, content: {
        PostMockView()
      })
      
    }
    .task {
      await model.loadCategories()
    }
    .alert(isPresented: $model.errorAlertIsPresented, content: {
      Alert(title: Text("Error"), message: Text(model.errorMessage), dismissButton: .cancel())
    })
  }
}

final class ViewModel: ObservableObject {

  @Published var categories: [String] = []
  @Published var entries: [Entry] = []
  @Published var random: Entry?
  @Published var isLoading = false
  @Published var errorMessage: String = "" {
    didSet {
      if errorMessage.isEmpty == false {
        errorAlertIsPresented = true
      }
    }
  }

  @Published var errorAlertIsPresented: Bool = false

  @MainActor
  func loadCategories() async  {
    defer { isLoading = false }
    isLoading = true
    let req = HTTPRequest(method: .get, scheme: "https", authority: "api.publicapis.org", path: "/categories")
    do {
      let (data, _) = try await URLSession.shared.data(for: req)
      self.categories = try JSONDecoder().decode(CategoriesResponse.self, from: data).categories
    } catch {
      errorMessage = "\(error)"
    }
  }

  @MainActor
  func random1() async  {
    self.random = nil
    var req = HTTPRequest(method: .get, scheme: "https", authority: "api.publicapis.org", path: "/random")
    req.headerFields[.PostMock.xRequestId] = "1122734-94924c70-58df-482a-811d-ff1bb0b03edf"

    do {
      let (data, _) = try await URLSession.shared.data(for: req)
      self.random = try JSONDecoder().decode(EntriesResponse.self, from: data).entries.first
    } catch {
      errorMessage = "\(error)"
    }
  }

  @MainActor
  func random2() async  {
    self.random = nil
    var req = HTTPRequest(method: .get, scheme: "https", authority: "api.publicapis.org", path: "/random")
    req.headerFields[.PostMock.xRequestId] = "1122734-c5751f7c-7e38-42b0-82d4-7fcfb57fc79a"
    do {
      let (data, _) = try await URLSession.shared.data(for: req)
      self.random = try JSONDecoder().decode(EntriesResponse.self, from: data).entries.first
    } catch {
      errorMessage = "\(error)"
    }
  }

  @MainActor
  func loadEntries(category: String) async {
    defer { isLoading = false }
    isLoading = true
    self.entries = []
    var req = HTTPRequest(method: .get, scheme: "https", authority: "api.publicapis.org", path: "/entries?category=\(category)")
    req.setCallId()
    do {
      let (data, _) = try await URLSession.shared.data(for: req)
      self.entries = try JSONDecoder().decode(EntriesResponse.self, from: data).entries
    } catch let error as DecodingError {
      if let callId = req.headerFields[.PostMock.xCallId] {
        PostMock.shared.decodeError(callID: callId, error: error)
      }
      errorMessage = "\(error)"
    }
    catch {
      errorMessage = "\(error)"
    }
  }

}

struct CategoriesResponse: Decodable {
  let categories: [String]
}

struct EntriesResponse: Decodable {
  let entries: [Entry]
}

struct Entry: Decodable, Hashable, Identifiable {
  var id: String { api }

  let api: String
  let description: String
  let link: String

  enum CodingKeys: String, CodingKey {
    case api = "API"
    case description = "Description"
    case link = "Link"
  }
}
