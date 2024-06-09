// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(visionOS)

import Foundation
import UIKit
import Pulse
import SwiftUI

/// Shows the console inside the navigation controller.
///
/// - note: Use ``ConsoleView`` directly to show it in the existing navigation
/// controller or other container controller.
public final class MainViewController: UIViewController {
    private let environment: ConsoleEnvironment

    public static var isAutomaticAppearanceOverrideRemovalEnabled = true

    public init(store: LoggerStore = .shared) {
        self.environment = ConsoleEnvironment(store: store)
        super.init(nibName: nil, bundle: nil)

        if MainViewController.isAutomaticAppearanceOverrideRemovalEnabled {
            removeAppearanceOverrides()
        }
        let console = ConsoleView(environment: environment)
        let vc = UIHostingController(rootView: NavigationView { console })
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private var isAppearanceCleanupNeeded = true

private func removeAppearanceOverrides() {
    guard isAppearanceCleanupNeeded else { return }
    isAppearanceCleanupNeeded = false

    let appearance = UINavigationBar.appearance(whenContainedInInstancesOf: [MainViewController.self])
    appearance.tintColor = nil
    appearance.barTintColor = nil
    appearance.titleTextAttributes = nil
    appearance.isTranslucent = true
}

#endif
