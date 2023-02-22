//
//  NetworkDebugVIew.swift
//  ios-client
//
//  Created by Praanto on 2023-02-22.
//

import Logging
import SwiftUI

struct NetworkDebugView: View {
    @ObservedObject private var nkKit = NetworkKit()
    private let logger = Logger(label: Logger.TAG_WS)
    @State private var showAlert = false
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Text("Connection status")
                    Spacer()
                    Text(nkKit.socketHasBeenEstablished ? "Connected" : "Disconnected")
                        .foregroundStyle(.secondary)
                }
                
                Button("Connect to server") {
                    Task {
                        do {
                            logger.info("Connecting to server ws://192.168.0.101:8080")
                            try await nkKit.connectToServer("ws://192.168.0.101:8080")
                            nkKit.startListening()
                        } catch {
                            logger.info("Connection succeeded")
                        }
                    }
                }
                
                Button("Send Message") {
                    Task {
                        showAlert.toggle()
                    }
                }
            }.navigationTitle("Network Debug View")
                .alert("Send message to server", isPresented: $showAlert) {
                    TextField("", text: $message)
                    Button("Send", role: .cancel) {
                        Task {
                            try await nkKit.sendMessage(message)
                        }
                    }
                    Button("Cancel", role: .destructive, action: {})
                } message: {
                    Text("Enter your message to send to the server.")
                }
        }
    }
}

struct NetworkDebugVIew_Previews: PreviewProvider {
    static var previews: some View {
        NetworkDebugView()
    }
}
