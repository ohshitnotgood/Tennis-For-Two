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

/// Main entry point view of the app.
struct ContentView: View {
    @State private var showNetworkSettingsSheet     = false
    @State private var showFeatureNotImplemented    = false
    
    @State private var serverMessage                = ""
    @State private var anyErrorAlertMessage         = ""
    @State private var showAnyErrorAlert            = false
    @State private var serverResponse               = ""
    
    @ObservedObject private var session = NetworkKit()
    @ObservedObject private var motion = MotionKit()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("x_ax\ny_ax\nz_ax")
                        Spacer()
                        VStack {
                            Text("\(motion.accl_x)\n\(motion.accl_y)\n\(motion.accl_z)")
                                .foregroundStyle(.secondary)
                        }
                    }.monospaced()
                } header: {
                    Text("Accelerometer Data")
                }
                
                
//                Section {
//                    Button("Open Network Settings") {
//                        showNetworkSettingsSheet.toggle()
//                    }
//
//                } header: {
//                    Text("Network")
//                }
                
                Section {
                    HStack {
                        Text("ws")
                        TextField("", text: $session.socketServerAddress)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                            .textCase(.lowercase)
                            .introspectTextField { tf in
                                tf.becomeFirstResponder()
                            }
                    }
                    
                    Picker("Connection Mode", selection: $session.networkConnectionMode) {
                        ForEach(NetworkConnectionMode.allCases, id: \.self) {
                            Text($0.rawValue).tag(0)
                        }
                    }
                    
                    Button("Connect") {
                        Task {
                            try await session.connectToServer()
                        }
                    }
                    
                    Button("Disconnect") {
                        
                    }
                } header: {
                    Text("Socket")
                }
                
                Section {
                    HStack {
                        TextField("Send message", text: $serverMessage)
                        Button {
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
                
                Section {
                    Text(serverResponse)
                        .monospaced()
                } header: {
                    Text("Server Response")
                        
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
                do {
                    try motion.startUpdatingCoordinates()
                } catch {
                    print(error.localizedDescription)
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
