// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Network
import Pulse
import Combine

@available(iOS 15, visionOS 1.0, *)
struct RemoteLoggerEnterPasswordView: View {
    @ObservedObject var viewModel: RemoteLoggerSettingsViewModel
    @ObservedObject var logger: RemoteLogger = .shared

    let server: RemoteLoggerServerViewModel

    @State private var passcode = ""

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        Form {
            Section(content: {
                SecureField("Password", text: $passcode)
                    .focused($isTextFieldFocused)
                    .submitLabel(.continue)
                    .onSubmit {
                        connect()
                    }
            }, footer: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Enter the password for '\(server.name)'.")
                }
            })
        }
        .inlineNavigationTitle("Enter Password")
#if os(iOS) || os(visionOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", role: .cancel) {
                    viewModel.pendingPasscodeProtectedServer = nil
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Connect") {
                    connect()
                }
            }
        }
#endif
        .onAppear {
            isTextFieldFocused = true
        }
    }

    private func connect() {
        viewModel.pendingPasscodeProtectedServer = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            viewModel.connect(to: server, passcode: passcode)
        }
    }
}
