//
//  NetworkKit.swift
//  ios-client
//
//  Created by Praanto on 2023-02-16.
//

import Logging
import SwiftUI
import Combine

/// Handles sending and receiving websocket data in this project.
class NetworkKit: NSObject, ObservableObject {
    @Published private var socket: URLSessionWebSocketTask? = nil
    private let logger = Logger(label: Logger.TAG_WS)
    
    @Published var socketHasBeenEstablished = false
    
    /// Attempts to connect to a WebSocket server using the provided `ws` address.
    ///
    /// Does  **not** try to validate if the URL is a websocket or an HTTP url.
    ///
    /// Additionally, this function should throw an error if the provided address
    /// is not `ws`.
    func connectToServer(_ address: String) async throws {
        logger.info("Connectiong to server at address: \(address)")
        guard let url = URL(string: address) else {
            throw ConnectionFailedError.InvalidAddress
        }
        
        self.socket = URLSession(configuration: .default, delegate: self, delegateQueue: nil).webSocketTask(with: url)
        
        guard let socket = socket else {
            throw ConnectionFailedError.AddressNotInWebSocketFormat
        }
        
        socket.resume()
        DispatchQueue.main.async {
            self.socketHasBeenEstablished = true
        }
    }

    /// Asynchronously sends message to the websocket server.
    ///
    /// Will throw an error if the connection has not been established.
    func sendMessage(_ message: String) async throws {
        if !self.socketHasBeenEstablished {
            throw ConnectionFailedError.SocketNotEstablished
        }
        
        logger.info("Sending data to websocket server.")
        let message = URLSessionWebSocketTask.Message.string(message)
        try await socket?.send(message)
        logger.info("Sent message to server.")
    }
    
    
    /// Starts listening for incoming data from the server in the background.
    ///
    /// Will throw error if device is not connected to any server. Use ``connectToBoard(_:)`` first before calling this function.
    ///
    /// It is **not** required to call this function inside a `Task` block or inside an `async`function as it already launches a `DispatchQueue` with label `background-socket`.
    func startListening() {
        DispatchQueue(label: "background-socket", qos: .background).async {
            self.socket?.receive(completionHandler: { (result) in
                switch result {
                    case .success(let message):
                        switch message {
                            case .data(let data): self.logger.info("Received data from server: \(data)")
                            case .string(let string): self.logger.info("Received string message from server: \(string)")
                            @unknown default: return
                        }
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            })
            
            self.startListening()
        }
    }
}

extension NetworkKit: URLSessionWebSocketDelegate {
}
