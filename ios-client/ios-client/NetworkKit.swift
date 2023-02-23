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
    private let logger = Logger(label: Logger.TAG_WS)
    private let queue = DispatchQueue(label: DispatchQueue.NETWORK_SOCKET, qos: .background)
    private var expectedHandshakeResponse = ""
    
    var socket: URLSessionWebSocketTask? = nil
    
    @Published var socketHasBeenEstablished = false
    @Published var socketServerAddress = "192.168.0.101:8080"
    @Published var networkConnectionMode: NetworkConnectionMode = .clientSlave
    
    /// Attempts to connect to a WebSocket server using the provided `ws` address.
    ///
    /// Does  **not** try to validate if the URL is a websocket or an HTTP url.
    ///
    /// Additionally, this function should throw an error if the provided address
    /// is not `ws`.
    func connectToServer() async throws {
        logger.info("Connectiong to server at address: ws://\(socketServerAddress)")
        guard let url = URL(string: "ws://\(socketServerAddress)") else {
            logger.error("Received an invalid address.")
            throw ConnectionFailedError.InvalidAddress
        }
        self.socket = URLSession(configuration: .default, delegate: self, delegateQueue: nil).webSocketTask(with: url)
        guard let socket = socket else {
            logger.info("Failed to establish socket connection.")
            throw ConnectionFailedError.AddressNotInWebSocketFormat
        }
        
        logger.info("Resuming socket session.")
        socket.resume()
        try await doInitialHandshake()
    }
    
    /// Does an initial handshake and sets all connection flags to true. 
    private func doInitialHandshake() async throws {
        switch networkConnectionMode {
            case .clientMaster:
                self.expectedHandshakeResponse = "handshake-acknowledged__client-master"
                logger.info("Sending client-master handshake request.")
                try await socket?.send(URLSessionWebSocketTask.Message.string("initial-handshake__client-master"))
            case .clientSlave:
                self.expectedHandshakeResponse = "handshake-acknowledged__client-slave"
                logger.info("Sending client-slave handshake request.")
                try await socket?.send(URLSessionWebSocketTask.Message.string("initial-handshake__client-slave"))
        }
        
        logger.info("Awaiting response")
        let response = try await self.startListening()
        
        guard let response = response else {
            logger.info("Failed to get a response")
            throw ConnectionFailedError.ResponseTimeout
        }
        logger.info("Received a response. Attempting to parse")
        
        if response == expectedHandshakeResponse {
            logger.info("Handshake successful")
            DispatchQueue.main.async {
                self.socketHasBeenEstablished = true
            }
        } else {
            logger.error("Handshake not successful")
            throw ConnectionFailedError.HandshakeFailed
        }
    }

    /// Asynchronously sends message to the websocket server.
    ///
    /// Will throw an error if the connection has not been established.
    @discardableResult
    func sendMessage(_ message: String) async throws -> String? {
        if !self.socketHasBeenEstablished {
            throw ConnectionFailedError.SocketNotEstablished
        }
        
        logger.info("Sending data to websocket server.")
        let message = URLSessionWebSocketTask.Message.string(message)
        try await socket?.send(message)
        logger.info("Sent message to server.")
        
        return try await self.startListening()
    }
    
    
    /// Starts listening for incoming data from the server in the background.
    ///
    /// Will throw error if device is not connected to any server. Use ``connectToBoard(_:)`` first before calling this function.
    ///
    /// It is **not** required to call this function inside a `Task` block or inside an `async`function as it already launches a `DispatchQueue` with label `background-socket`.
    @discardableResult
    func startListening() async throws -> String? {
        let response = try await self.socket?.receive()
        
        switch response {
            case .string(let string):
                return string
            case .data(_):
                logger.error("Received `data` as a response which is not parsable.")
                throw ConnectionFailedError.UnparsableResponseData
            case .none:
                logger.info("Received no data as a response.")
                return nil
            case .some(_):
                logger.error("Received unparsable data as response.")
                throw ConnectionFailedError.UnparsableResponseData
        }
    }
    
}

extension NetworkKit: URLSessionWebSocketDelegate {
}
