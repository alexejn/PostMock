// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

// MARK: - View

@available(iOS 15, visionOS 1.0, *)
struct NetworkInspectorMetricsView: View {
    let viewModel: NetworkInspectorMetricsViewModel

    var body: some View {
#if os(tvOS)
        ForEach(viewModel.transactions) {
            NetworkInspectorTransactionView(viewModel: $0)
        }
#else
        List {
            ForEach(viewModel.transactions) {
                NetworkInspectorTransactionView(viewModel: $0)
            }
        }
#if os(iOS) || os(visionOS)
        .listStyle(.insetGrouped)
#endif
#if os(macOS)
        .backport.hideListContentBackground()
#endif
#if !os(macOS)
        .navigationTitle("Metrics")
#endif
#endif
    }
}

// MARK: - ViewModel

final class NetworkInspectorMetricsViewModel {
    private(set) lazy var transactions = task.orderedTransactions.map {
        NetworkInspectorTransactionViewModel(transaction: $0, task: task)
    }

    private let task: NetworkTaskEntity

    init?(task: NetworkTaskEntity) {
        guard task.hasMetrics else { return nil }
        self.task = task
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 15, visionOS 1.0, *)
struct NetworkInspectorMetricsView_Previews: PreviewProvider {
    static var previews: some View {
#if os(macOS)
        NetworkInspectorMetricsView(viewModel: .init(
            task: LoggerStore.preview.entity(for: .createAPI)
        )!).previewLayout(.fixed(width: 500, height: 800))
#else
        NavigationView {
            NetworkInspectorMetricsView(viewModel: .init(
                task: LoggerStore.preview.entity(for: .createAPI)
            )!)
        }
#endif
    }
}
#endif

