// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(macOS) || os(visionOS)

import SwiftUI
import Pulse
import CoreData
import Combine

@available(iOS 15, visionOS 1.0, *)
struct ConsoleSearchSuggestionView: View {
    let suggestion: ConsoleSearchSuggestion
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if case .apply(let token) = suggestion.action {
                    switch token {
                    case .filter:
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.accentColor)
                    case .term:
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.accentColor)
                    }
                } else {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.secondary)
                }
                Text(suggestion.text)
                    .lineLimit(1)
                Spacer()
            }
        }
    }
}

struct ShortcutTooltip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.separator)
            .background(Rectangle().frame(width: 34, height: 28).foregroundColor(Color.separator.opacity(0.2)).cornerRadius(8))
    }
}

#endif
