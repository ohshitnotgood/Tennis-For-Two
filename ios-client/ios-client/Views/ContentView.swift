//
//  ContentView.swift
//  ios-client
//
//
//  This file contains declaration of the main entry view of the app.
//
//  Created by Praanto on 2023-02-12.
//

import SwiftUI
import Logging

/// Main entry point view of the app.
struct ContentView: View {
    @State private var showNetworkSettingsSheet     = false
    @State private var showFeatureNotImplemented    = false
    
    @FocusState private var fieldHasFocus: Bool
    
    @State private var serverMessage                = ""
    @State private var anyErrorAlertMessage         = ""
    @State private var showAnyErrorAlert            = false
    @State private var serverResponse               = ""
    
    private let logger = Logger(label: Logger.TAG_CONTENT_VEIW)
    
    @ObservedObject private var session = NetworkKit()
    @ObservedObject private var motion = MotionKit()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("x_ax\ny_ax\nz_ax")
                        Spacer()
                        Text("\(motion.user_accl_x)\n\(motion.user_accl_y)\n\(motion.user_accl_z)")
                            .foregroundStyle(.secondary)
                    }.monospaced()
                } header: {
                    Text("Accelerometer Data")
                }
                
                Section {
                    HStack {
                        Text("ws")
                        TextField("", text: $session.socketServerAddress)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                            .textCase(.lowercase)
                            .focused($fieldHasFocus)
                            .truncationMode(.head)
                            .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.interactively)
                            .submitLabel(SubmitLabel.go)
                            .onSubmit {
                                fieldHasFocus = false
                            }
                    }
                    
                    Picker("Connection Mode", selection: $session.networkConnectionMode) {
                        ForEach(NetworkConnectionMode.allCases, id: \.self) {
                            Text($0.rawValue).tag(0)
                        }
                    }.onChange(of: session.networkConnectionMode) { _ in
                        logger.info("ConnectionMode picker changed.")
                    }
                    
                    Button(session.socketHasBeenEstablished ? "Reonnect" : "Connect") {
                        logger.info("Connect/Reconnect button clicked.")
                        Task {
                            try await session.connectToServer()
                        }
                    }
                    
                    if session.socketHasBeenEstablished {
                        Button("Disconnect") {
                            logger.info("Disconnect button clicked.")
                        }
                        
                        if session.networkConnectionMode == .clientSlaveSync {
                            Button("Start Listening") {
                                Task {
                                    logger.info("StartListening button clicked.")
//                                    session.shouldContinueListeningForNewData = true
                                    do {
                                        try await session.startListeningSync()
                                    } catch {
                                        logger.error("Caught error in the listener button")
                                    }
                                }
                            }
                        }
                        
                        Button("Stop Listening") {
                            Task {
                                logger.info("StopListening button clicked")
                                try await session.stopListeningSync()
                            }
                        }
                        
                        if session.networkConnectionMode == .clientMaster {
                            Button("Start Broadcasting") {
                                logger.info("StartBoardcasting button clicked.")
                            }
                        }
                    }
                } header: {
                    Text("Socket Configuration")
                }
                
                if session.socketHasBeenEstablished {
                    withAnimation {
                        Section {
                            HStack {
                                TextField("Send message", text: $serverMessage)
                                Button {
                                    logger.info("SendMessage button clicked.")
                                    Task {
                                        do {
                                            serverResponse = try await session.sendMessage(serverMessage) ?? "error"
                                            serverMessage = ""
                                        } catch {
                                            showErrorAlert(error.localizedDescription)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "paperplane.circle.fill")
                                }
                                .buttonBorderShape(.capsule)
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                    
                    withAnimation {
                        Section {
                            Text(serverResponse)
                                .monospaced()
                        } header: {
                            Text("Server Response")
                            
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    VStack {
                        Text(session.socketHasBeenEstablished ? "Connected to " : "Disconnected")
                            .font(.footnote)
                        
                        if session.socketHasBeenEstablished {
                            Text(session.socketServerAddress)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showNetworkSettingsSheet, content: {
                NetworkSettingsView()
                    .environmentObject(session)
            })
            // MARK: Feature Implement alert
            .alert("Feature not implemented", isPresented: $showFeatureNotImplemented, actions: {
                Button("Cancel", role: .cancel) {
                }
            }, message: {
                Text("This feature has not been implemented and thus cannot be invoked.")
            })
            .alert("An unexpected error occurred", isPresented: $showAnyErrorAlert, actions: {
                Button("Done", role: .cancel) {
                    anyErrorAlertMessage = ""
                }
            }, message: {
                Text(anyErrorAlertMessage)
            })
            // MARK: onAppear
            .onAppear {
                logger.info("Initialising ContentView()")
                do {
                    logger.info("Starting pulling data from the sensors.")
                    try motion.startUpdatingCoordinates()
                } catch {
                    logger.error("\(error.localizedDescription)")
                }
            }
            .navigationTitle("App Debug")
        }
    }
    
    private func showErrorAlert(_ message: String) {
        anyErrorAlertMessage = message
        showAnyErrorAlert.toggle()
    }
}

// MARK: Previews
@available(*, unavailable)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SettingsValueStore())
    }
}
