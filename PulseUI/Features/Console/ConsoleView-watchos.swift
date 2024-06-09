// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(watchOS)

import SwiftUI
import Pulse

public struct ConsoleView: View {
    @StateObject private var environment: ConsoleEnvironment
    @StateObject private var listViewModel: IgnoringUpdates<ConsoleListViewModel>

    init(environment: ConsoleEnvironment) {
        _environment = StateObject(wrappedValue: environment)
        let listViewModel = ConsoleListViewModel(environment: environment, filters: environment.filters)
        _listViewModel = StateObject(wrappedValue: .init(listViewModel))
    }

    public var body: some View {
        List {
            ConsoleToolbarView(environment: environment)
            ConsoleListContentView()
                .environmentObject(listViewModel.value)
        }
        .navigationTitle(environment.title)
        .onAppear { listViewModel.value.isViewVisible = true }
        .onDisappear { listViewModel.value.isViewVisible = false }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { environment.router.isShowingSettings = true }) {
                    Image(systemName: "gearshape").font(.title3)
                }
            }
        }
        .injecting(environment)
    }
}

private struct ConsoleToolbarView: View {
    @ObservedObject private var environment: ConsoleEnvironment
    @ObservedObject private var viewModel: ConsoleFiltersViewModel
    @Environment(\.router) private var router

    init(environment: ConsoleEnvironment) {
        self.environment = environment
        self.viewModel = environment.filters
    }

    var body: some View {
        HStack {
            if environment.initialMode == .all {
                Button(action: { environment.bindingForNetworkMode.wrappedValue.toggle() } ) {
                    Image(systemName: "arrow.down.circle")
                }
                .background(environment.bindingForNetworkMode.wrappedValue ? Rectangle().foregroundColor(.blue).cornerRadius(8) : nil)
            }
            Button(action: { viewModel.options.isOnlyErrors.toggle() }) {
                Image(systemName: "exclamationmark.octagon")
            }
            .background(viewModel.options.isOnlyErrors ? Rectangle().foregroundColor(.red).cornerRadius(8) : nil)

            Button(action: { router.isShowingFilters = true }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
            .background(viewModel.isDefaultFilters(for: environment.mode) ? nil : Rectangle().foregroundColor(.blue).cornerRadius(8))
        }
            .font(.title3)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 8))
    }
}

#if DEBUG
struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConsoleView(store: .mock)
        }
        .navigationViewStyle(.stack)
    }
}
#endif

#endif
