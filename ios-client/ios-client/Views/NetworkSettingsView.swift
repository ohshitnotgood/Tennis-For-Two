//
//  NetworkSettingsView.swift
//  ios-client
//
//  Created by Praanto on 2023-02-22.
//

import SwiftUI

struct NetworkSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var addressString = "ws:"
    @State private var serverMessage = ""
    @State private var navigationBarTitle = "Network Settings"
    
    @EnvironmentObject var network: NetworkKit
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Address")
                            .padding(.trailing)
                        TextField("", text: $network.socketServerAddress)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                            .textCase(.lowercase)
                            .introspectTextField { tf in
                                tf.becomeFirstResponder()
                            }
                    }
                } footer: {
                    Text("Your address must include `ws:` or a `wss:` to specify WebSocket protocol. Only WebSocket addresses are supported.")
                }
                
                Section {
                    Picker("Connection Mode", selection: $network.networkConnectionMode) {
                        ForEach(NetworkConnectionMode.allCases, id: \.self) {
                            Text($0.rawValue).tag(0)
                        }
                    }
                } footer: {
                    Text(network.networkConnectionMode == .clientSlave ? "Your device will now send data to the server when it receives a request to do so." : "Data will periodically be sent to the server, regardless if the server is ready to handle data.")
                }
                
                Section {
                    
                }
            }.navigationTitle(navigationBarTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Connect", role: .destructive) {
                            navigationBarTitle = "Connecting..."
                            Task {
                                do {
                                    try await network.connectToServer()
                                    navigationBarTitle = "Connected"
                                } catch {
                                    
                                }
                            }
                        }
                    }
                }
        }
    }
}

enum NetworkConnectionMode: String, Hashable, CaseIterable {
    case clientMaster = "Client Master"
    case clientSlave = "Client Slave"
}

@available(*, unavailable)
struct NetworkSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSettingsView()
            .environmentObject(NetworkKit())
    }
}
