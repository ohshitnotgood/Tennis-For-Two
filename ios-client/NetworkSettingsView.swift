//
//  NetworkSettingsView.swift
//  ios-client
//
//  Created by Praanto on 2023-02-22.
//

import SwiftUI

struct NetworkSettingsView: View {
    @State private var addressString = "ws:"
    @State private var connectionMode: NetworkConnectionMode = .clientSlave
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Socket Address")
                        .padding(.trailing)
                    TextField("", text: $addressString)
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
                Picker("Connection Mode", selection: $connectionMode) {
                    ForEach(NetworkConnectionMode.allCases, id: \.self) {
                        Text($0.rawValue).tag(0)
                    }
                }
            } footer: {
                Text(connectionMode == .clientSlave ? "Your device will now send data to the server when it receives a request to do so." : "Data will periodically be sent to the server, regardless if the server is ready to handle data.")
            }
        }.navigationTitle("Network Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Connect", role: .destructive) {
                        
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
    }
}
