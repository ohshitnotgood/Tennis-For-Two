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
    @State private var showCoordinatesHistory       = false
    @State private var showAppLog                   = false
    @State private var showCreditsSheet             = false
    @State private var showConnectToBoardSheet      = false
    @State private var showRefreshRateAlert         = false
    @State private var showFeatureNotImplemented    = false
    @State private var hasConnectionBeenEstablished = false
    
    @State private var anyErrorAlertMessage         = ""
    @State private var showAnyErrorAlert            = false
    
    private var networkKit                          = NetworkKit()
    
    @ObservedObject private var kit                 = MotionKit()
    @EnvironmentObject private var settings         : SettingsValueStore
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Xpc, Ypc")
                        Spacer()
                        Text("\(kit.x), \(kit.y)")
                            .foregroundColor(.secondary)
                            .monospaced()
                    }
                } header: {
                    Text("Coordinates")
                }
                
                // MARK: Config section
                Section {
                    HStack {
                        Text("Sensor refresh rate")
                        Spacer()
                        Text("\(Int(settings.sensorDataRefreshRate))Hz")
                            .foregroundColor(.secondary)
                            .monospaced()
                    }
                    
                    
                    HStack {
                        Text("Sensitivity")
                        Spacer()
                        Text("\(settings.sensitivity)")
                            .foregroundColor(.secondary)
                            .monospaced()
                    }
                    
                    HStack {
                        HStack {
                            Text("Connection Status")
                            Spacer()
                            Text(networkKit.socketHasBeenEstablished ? "Connected" : "Disconnected")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("IP Address")
                        Spacer()
                        Text("-")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Latency")
                        Spacer()
                        Text("-")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Configurations")
                }
                
#if DEBUG
                // MARK: Accelerometer Section
                Section {
                    HStack {
                        Text("x")
                        Spacer()
                        Text(String(kit.accl_x))
                            .monospaced()
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("y")
                        Spacer()
                        Text(String(kit.accl_y))
                            .monospaced()
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("z")
                        Spacer()
                        Text(String(kit.accl_z))
                            .monospaced()
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Max Pos")
                        Spacer()
                        Text(String(kit.maxNegativeXAccelerationDetected))
                            .monospaced()
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Max Y")
                        Spacer()
                        Text(String(kit.maxNegativeXAccelerationDetected))
                            .monospaced()
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Resume sensor update") {
                        do {
                            try kit.startUpdatingCoordinates()
                        } catch {
                        }
                    }
                    
                } header: {
                    Text("Accelerometer Data")
                }
#endif
                
                // MARK: Network Section
                Section {
                    Button("Connect to the board") {
                        showConnectToBoardSheet.toggle()
                    }
                    Button("Send Sample Message") {
                        Task {
                            do {
                                try await networkKit.sendMessage("sup yall")
                            } catch {
                                anyErrorAlertMessage = error.localizedDescription
                                showAnyErrorAlert.toggle()
                            }
                        }
                    }
                } header: {
                    Text("Network")
                }
            }
            .sheet(isPresented: $showCoordinatesHistory, content: {
                CoordinatesListingView()
            })
            .sheet(isPresented: $showCreditsSheet, content: {
                CreditsView()
            })
            .sheet(isPresented: $showConnectToBoardSheet, content: {
                NetworkSettingsView()
            })
            // MARK: Feature Implement alert
            .alert("Feature not implemented", isPresented: $showFeatureNotImplemented, actions: {
                Button("Cancel", role: .cancel) {
                }
            }, message: {
                Text("This feature has not been implemented and thus cannot be invoked.")
            })
            .alert("An unexpected error occurred", isPresented: $showAnyErrorAlert, actions: {
                Button("Okay", role: .cancel) {
                    
                }
            }, message: {
                Text(anyErrorAlertMessage)
            })
            .onAppear {
                do {
                    try kit.startUpdatingCoordinates()
                } catch {
                    print(error.localizedDescription)
                }
            }
            .navigationTitle("App Debug")
        }
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
