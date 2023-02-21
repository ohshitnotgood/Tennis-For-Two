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
    @State private var showConnectToBoardAlert      = false
    @State private var showRefreshRateAlert         = false
    @State private var showFeatureNotImplemented    = false
    @State private var hasConnectionBeenEstablished = false
    
    
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
                        Text("Connection Status")
                        Spacer()
                        Text("Disconnected")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        HStack {
                            Text("Connection Status")
                            Spacer()
                            Text(String(settings.connectionStatus))
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
                    
                } header: {
                    Text("Accelerometer Data")
                }
#endif
                
                // MARK: Network Section
                Section {
                    Button("Connect to the board") {
                        showFeatureNotImplemented.toggle()
                    }
                    Button("View network log") {
                        showFeatureNotImplemented.toggle()
                        
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
            .alert("Connect to the chip kit", isPresented: $showConnectToBoardAlert, actions: {
                TextField("URL", text: $settings.boardIPAddress)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
                
                Button("Cancel", role: .destructive, action: {
                    
                })
                
                Button("Connect", role: .cancel, action: {
                    
                })
            }, message: {
                Text("Enter the IP address to establish connection with the board.")
            })
            .alert("Feature not implemented", isPresented: $showFeatureNotImplemented, actions: {
                Button("Cancel", role: .cancel) {
                    
                }
            }, message: {
                Text("This feature has not been implemented and thus cannot be invoked.")
            })
            .onAppear {
                do {
                    try kit.startUpdatingCoordinates()
                } catch {
                    print(error.localizedDescription)
                }
            }
            .navigationTitle("ios-client")
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
