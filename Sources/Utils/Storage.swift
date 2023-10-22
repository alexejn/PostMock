//
// Created by Alexey Nenastyev on 11.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import os

struct Storage {
  var logger = Logger(subsystem: "storage", category: "storage")
  var folder: String?

  struct File {
    let filename: String

    init(filename: String) {
      self.filename = filename
    }

    func url(directory: URL) -> URL {
      directory.appendingPathComponent(filename)
    }
  }

  private func directory(create: Bool = true ) throws -> URL
  {
    let url = try FileManager.default.url(for: .documentDirectory,
                                          in: .userDomainMask,
                                          appropriateFor: nil,
                                          create: create)
    if let folder = folder {
      return url.appendingPathComponent(folder)
    } else {
      return url
    }
  }


  func restore<T:Decodable>(from file: File) async -> T? {
    let task = Task<T?, Error> {
      let directory = try directory()
      let fileURL = file.url(directory: directory)
      guard let data = try? Data(contentsOf: fileURL) else {
        return nil
      }
      let dailyScrums = try JSONDecoder().decode(T.self, from: data)
      return dailyScrums
    }

    do {
      let value = try await task.value
      //      Logger.postmock.notice("Restored: \(T.self) from \(file.fileName)\n\(value.debugDescription)")
      return value
    } catch {
      logger.error("Can't restore \(T.self) from \(file.filename) \(error)")
      return nil
    }
  }

  func store<T:Encodable>(data: T, to file: File) async throws {
    let task = Task {
      do {
        let directory = try directory()
        let fileURL = file.url(directory: directory)
        let encodedData = try JSONEncoder().encode(data)
        try encodedData.write(to: fileURL)
      } catch {
        logger.error("Can't store \(T.self) to \(file.filename) \(error)")
        throw error
      }
    }
    _ = try await task.value
    //    Logger.postmock.notice("Stored: \(T.self) to \(file.fileName)")
  }

  func remove(file: File) {
    do {

      let directory = try directory()
      let url = file.url(directory: directory)
//      guard FileManager.default.fileExists(atPath: url.absoluteString) else { return }
      try? FileManager.default.removeItem(at: url)
      //      Logger.postmock.notice("Remover:  \(file.fileName)")
    } catch {
      logger.error("Can't remove file \(file.filename) \(error)")
    }
  }

  func clearFolder() {
    guard let folder = folder else { return }
    do {
      let directory = try directory(create: false)
      try FileManager.default.removeItem(at: directory)
    } catch {
      logger.error("Can't remove direcotry \(folder) \(error)")
    }
  }
}
