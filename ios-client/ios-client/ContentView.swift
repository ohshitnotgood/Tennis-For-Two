//
//  ContentView.swift
//  ios-client
//
//  Created by Praanto on 2023-02-12.
//

import SwiftUI
import LabeledStepper

/// Main entry point view of the app.
struct ContentView: View {
    @State private var showCoordinatesHistory       = false
    @State private var showAppLog                   = false
    @State private var showCreditsSheet             = false
    @State private var showConnectToBoardAlert      = false
    @State private var showRefreshRateAlert         = false
    @State private var showFeatureNotImplemented    = false
    @State private var hasConnectionBeenEstablished = false
    
    @State private var boardIPAddress               = ""
    
    @ObservedObject private var kit                 = MotionKit()
    @ObservedObject private var settings            = SettingsValueStore()
    
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
                        Text("\(settings.sensorDataRefreshRate)Hz")
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
                        Text("\(kit.accl_x)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("y")
                        Spacer()
                        Text("\(kit.accl_y)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("z")
                        Spacer()
                        Text("\(kit.accl_z)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Accelerometer Data")
                }
                
                // MARK: Gyro Section
                Section {
                    HStack {
                        Text("x")
                        Spacer()
                        Text("\(kit.tilt_x)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("y")
                        Spacer()
                        Text("\(kit.tilt_y)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("z")
                        Spacer()
                        Text("\(kit.tilt_z)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Gyro Data")
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
            .alert("Adjust refresh rate", isPresented: $showRefreshRateAlert, actions: {
                Slider(
                    value: $settings.sensorDataRefreshRate,
                    in: 1...100
                )
            }, message: {
                Text("Slide to adjust the sensor refresh rate")
            })
            .alert("Connect to the chip kit", isPresented: $showConnectToBoardAlert, actions: {
                TextField("URL", text: $boardIPAddress)
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

struct LogItemView: View {
    let messageTitle: String
    let messageBody: String
    var body: some View {
        HStack {
            Text(messageTitle)
            Spacer()
            Text(messageBody)
        }.padding()
    }
}

struct CreditsView: View {
    var body: some View {
        NavigationView {
            VStack {
                
            }.navigationTitle("Acknowledgements")
        }
    }
}

struct CoordinatesListingView: View {
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Text(Date().formatted(date: .abbreviated, time: .complete))
                    Spacer()
                    Text("20.321\n21.3212")
                        .monospaced()
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Coordinates History")
        }
    }
}

/// Stores settings data for the app.
class SettingsValueStore: ObservableObject {
    @Published var sensorDataRefreshRate = 100.0
    @Published var connectionStatus = "Disconnected"
    @Published var sensitivity = 6
}

struct SensitivitySliderView: View {
    @State private var sensitivity = 0
    var body: some View {
        List {
            Section {
                HStack {
                    Stepper("Sensitivity: \(sensitivity)", value: $sensitivity, in: 0...10)
                }
            } header: {
                Text("Adjust Sensitivity")
            }
        }
    }
}


// MARK: Previews
@available(*, unavailable)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@available(*, unavailable)
struct CoordinatesListingView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatesListingView()
    }
}


@available(*, unavailable)
struct SensitivitySliderView_Previews: PreviewProvider {
    static var previews: some View {
        SensitivitySliderView()
    }
}
