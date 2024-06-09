// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import Foundation
import Pulse
import SwiftUI
import CoreData

enum LoggerEntity {
    /// Regular log, not task attached.
    case message(LoggerMessageEntity)
    /// Either a log with an attached task, or a task itself.
    case task(NetworkTaskEntity)

    init(_ entity: NSManagedObject) {
        if let message = entity as? LoggerMessageEntity {
            if let task = message.task {
                self = .task(task)
            } else {
                self = .message(message)
            }
        } else if let task = entity as? NetworkTaskEntity {
            self = .task(task)
        } else {
            fatalError("Unsupported entity: \(entity)")
        }
    }

    var task: NetworkTaskEntity? {
        if case .task(let task) = self { return task }
        return nil
    }
}

extension LoggerMessageEntity: Identifiable {
    public var id: NSManagedObjectID { objectID }
}

extension NetworkTaskEntity: Identifiable {
    public var id: NSManagedObjectID { objectID }
}

extension NetworkTaskEntity {
    var requestFileViewerContext: FileViewerViewModel.Context {
        FileViewerViewModel.Context(
            contentType: originalRequest?.contentType,
            originalSize: requestBodySize,
            metadata: metadata,
            isResponse: false,
            error: nil
        )
    }

    var responseFileViewerContext: FileViewerViewModel.Context {
        FileViewerViewModel.Context(
            contentType: response?.contentType,
            originalSize: responseBodySize,
            metadata: metadata,
            isResponse: true,
            error: decodingError
        )
    }

    /// - returns `nil` if the task is an unknown state. It may happen if the
    /// task is pending, but it's from the previous app run.
    func state(in store: LoggerStore) -> NetworkTaskEntity.State? {
        let state = self.state
        if state == .pending && self.session != store.session.id {
            return nil
        }
        return state
    }
}

extension LoggerMessageEntity {
    var logLevel: LoggerStore.Level {
        LoggerStore.Level(rawValue: level) ?? .debug
    }
}

extension NetworkTaskEntity.State {
    var tintColor: Color {
        switch self {
        case .pending: return .orange
        case .success: return .green
        case .failure: return .red
        }
    }

    var iconSystemName: String {
        switch self {
        case .pending: return "clock.fill"
        case .success: return "checkmark.circle.fill"
        case .failure: return "exclamationmark.octagon.fill"
        }
    }
}

extension LoggerSessionEntity {
    var formattedDate: String {
        formattedDate(isCompact: false)
    }

    var searchTags: [String] {
        possibleFormatters.map { $0.string(from: createdAt) }
    }

    func formattedDate(isCompact: Bool = false) -> String {
        if isCompact {
            return compactDateFormatter.string(from: createdAt)
        } else {
            return fullDateFormatter.string(from: createdAt)
        }
    }

    var fullVersion: String? {
        guard let version = version else {
            return nil
        }
        if let build = build {
            return version + " (\(build))"
        }
        return version
    }
}

private let compactDateFormatter = DateFormatter(dateStyle: .none, timeStyle: .medium)

#if os(watchOS)
private let fullDateFormatter = DateFormatter(dateStyle: .short, timeStyle: .short, isRelative: true)
#else
private let fullDateFormatter = DateFormatter(dateStyle: .medium, timeStyle: .medium, isRelative: true)
#endif

private let possibleFormatters: [DateFormatter] = [
    fullDateFormatter,
    DateFormatter(dateStyle: .long, timeStyle: .none),
    DateFormatter(dateStyle: .short, timeStyle: .none)
]
