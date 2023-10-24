//
// Created by Alexey Nenastyev on 9.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import PostMock

// MARK: Views
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
          List {
            Section {
              HStack {
                Button("Random #1") {
                  Task {
                    await model.random1()
                  }
                }
                Button("Random #2") {
                  Task {
                    await model.random2()
                  }
                }
              }
            }
            .foregroundColor(.mint)
            .buttonStyle(.bordered)
            Section("Categories") {
              ForEach(model.categories, id: \.self) { category in
                NavigationLink {
                  CategoryView(category: category, model: model)
                } label: {
                  Text(category)
                }
              }
            }
          }
        }
      }
      .navigationTitle("Public APIs")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("PostMock") {
            postMockViewPresented.toggle()
          }
          .buttonStyle(.bordered)
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

// MARK: View Model

final class ViewModel: NSObject, ObservableObject {

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

  /// When you use custom URLSession or configuration PostMockURLProtocol should be added to protocolClasses
  private lazy var customURLSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [PostMockURLProtocol.self]
    let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    return urlSession
  }()

  @Published var errorAlertIsPresented: Bool = false

  @MainActor
  func loadCategories() async  {
    defer { isLoading = false }
    isLoading = true
    let req = URLRequest(url: URL(string: "https://api.publicapis.org/categories")!)
    do {
      /// Used shared url session
      let (data, _) = try await URLSession.shared.data(for: req)
      self.categories = try JSONDecoder().decode(CategoriesResponse.self, from: data).categories
    } catch {
      errorMessage = "\(error)"
    }
  }

  @MainActor
  func random1() async -> Entry? {
    self.random = nil
    var req = URLRequest(url: URL(string: "https://api.publicapis.org/random")!)
    req.setValue("1122734-94924c70-58df-482a-811d-ff1bb0b03edf", forHTTPHeaderField: PostMock.Headers.xPostmanRequestId)

    do {
      /// Example with custom url session
      let (data, _) = try await customURLSession.data(for: req)
      self.random = try JSONDecoder().decode(EntriesResponse.self, from: data).entries.first
      return self.random
    } catch {
      errorMessage = "\(error)"
      return nil
    }
  }

  @MainActor
  func random2() async -> Entry? {
    self.random = nil
    var req = URLRequest(url: URL(string: "https://api.publicapis.org/random")!)
    req.setValue("1122734-c5751f7c-7e38-42b0-82d4-7fcfb57fc79a", forHTTPHeaderField: PostMock.Headers.xPostmanRequestId)
    do {
      /// Example with custom url session
      let (data, _) = try await customURLSession.data(for: req)
      self.random = try JSONDecoder().decode(EntriesResponse.self, from: data).entries.first
      return self.random
    } catch {
      errorMessage = "\(error)"
      return nil
    }
  }

  @MainActor
  func loadEntries(category: String) async {
    defer { isLoading = false }
    isLoading = true
    self.entries = []

    var req = URLRequest(url: URL(string: "https://api.publicapis.org/entries?category=\(category)")!)
    req.setCallId()
    do {
      let (data, _) = try await URLSession.shared.data(for: req)
      self.entries = try JSONDecoder().decode(EntriesResponse.self, from: data).entries
    } catch let error as DecodingError {
      if let callId = req.callID {
        PostMock.shared.decodeError(callID: callId, error: error)
      }
      errorMessage = "\(error)"
    }
    catch {
      errorMessage = "\(error)"
    }
  }

}

extension ViewModel: URLSessionDelegate {

}

// MARK: DTO

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
