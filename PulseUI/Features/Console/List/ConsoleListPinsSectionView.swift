// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(visionOS)

import CoreData
import Pulse
import Combine
import SwiftUI

@available(iOS 15, visionOS 1.0, *)
struct ConsoleListPinsSectionView: View {
    @ObservedObject var viewModel: ConsoleListViewModel

    var body: some View {
        let prefix = Array(viewModel.pins.prefix(3))

        PlainListExpandableSectionHeader(title: "Pins", count: viewModel.pins.count, destination: {
            ConsoleStaticList(entities: viewModel.pins)
                .inlineNavigationTitle("Pins")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.buttonRemovePinsTapped) {
                            Image(systemName: "trash")
                        }
                    }
                }
        }, isSeeAllHidden: prefix.count == viewModel.pins.count)

        ForEach(prefix, id: \.pinCellID, content: ConsoleEntityCell.init)

        Button(action: viewModel.buttonRemovePinsTapped) {
            Text("Remove Pins")
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.separator.opacity(0.2))
        .listRowSeparator(.hidden)
        .listRowSeparator(.hidden, edges: .bottom)
    }
}

private extension NSManagedObject {
    var pinCellID: PinCellId { PinCellId(id: objectID) }
}

private struct PinCellId: Hashable {
    let id: NSManagedObjectID
}

#endif
