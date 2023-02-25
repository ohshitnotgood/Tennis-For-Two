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
    private var expectedHandshakeResponse = ""
    private var socket: URLSessionWebSocketTask? = nil
    private var didSendInitialDataPullRequest = false
    
    @Published var shouldContinueListeningForNewData = false
    @Published var socketHasBeenEstablished = false
    @Published var socketServerAddress = "192.168.0.101:8080"
    @Published var networkConnectionMode: NetworkConnectionMode = .clientSlaveSync
    
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
                self.expectedHandshakeResponse = NetworkKit.InitialHandshake.acknowledgementClientMaster.rawValue
                logger.info("Sending client-master handshake request.")
                try await socket?.send(URLSessionWebSocketTask.Message.string(NetworkKit.InitialHandshake.clientMaster.rawValue))
            case .clientSlaveSync:
                self.expectedHandshakeResponse = NetworkKit.InitialHandshake.acknowledgementClientSlaveSync.rawValue
                logger.info("Sending client-slave-sync handshake request.")
                try await socket?.send(URLSessionWebSocketTask.Message.string(NetworkKit.InitialHandshake.clientSlaveSync.rawValue))
            case .clientSlaveAsync:
                self.expectedHandshakeResponse = NetworkKit.InitialHandshake.acknowledgementClientSlaveAsync.rawValue
                logger.info("Sending client-slave-async handshake request.")
                try await socket?.send(URLSessionWebSocketTask.Message.string(NetworkKit.InitialHandshake.clientSlaveAsync.rawValue))
        }
        
        logger.info("Awaiting response")
        let response = try await self.getServerResponse()
        
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
            logger.error("Socket has not been established")
            throw ConnectionFailedError.SocketNotEstablished
        }
        
        logger.info("Sending data to websocket server.")
        let message = URLSessionWebSocketTask.Message.string(message)
        try await socket?.send(message)
        logger.info("Sent message to server.")
        
        return try await self.getServerResponse()
    }
    
    
    /// Waits for a response from a server.
    ///
    /// Returns `nil` if the response received is not a `String`.
    @discardableResult
    private func getServerResponse() async throws -> String? {
        switch try await self.socket?.receive() {
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
    
    func startListeningSync() async throws {
        if networkConnectionMode != .clientSlaveSync {
            throw ConnectionFailedError.HandshakeFailed
        }
        
        if !socketHasBeenEstablished {
            throw ConnectionFailedError.SocketNotEstablished
        }
        
        logger.info("Starting listening via client-slave-sync protocol.")
        logger.info("Resuming socket")
        socket?.resume()
        
        if !didSendInitialDataPullRequest {
            try await socket?.send(URLSessionWebSocketTask.Message.string(NetworkKit.TransmissionRequest.initClientSlaveSync.rawValue))
        }
        
        
        guard let response = try await getServerResponse() else {
            // TODO: Put correct error here
            logger.error("Failed to get request from server.")
            throw ConnectionFailedError.UnparsableResponseData
        }
        
        logger.info("Received possible data pull request from the server.")
        
        if response == NetworkKit.ClientSlaveSyncProtocolMessage.dataRequestFromServer.rawValue {
            logger.info("Received data pull request from the server.")
            try await socket?.send(URLSessionWebSocketTask.Message.string("response"))
            logger.info("Responded to data pull request from the server.")
        }
        
        if shouldContinueListeningForNewData {
            try await startListeningSync()
        }
    }
    
    func stopListeningSync() async throws {
        try await socket?.send(URLSessionWebSocketTask.Message.string(NetworkKit.TransmissionRequest.killClientSlaveSync.rawValue))
        DispatchQueue.main.async {
            self.shouldContinueListeningForNewData = false
        }
    }
    
    func startListeningAsync() throws {
        if networkConnectionMode != .clientSlaveSync {
            throw ConnectionFailedError.HandshakeFailed
        }
    }
    
    func startBroadcasting() {
        
    }
    
}

extension NetworkKit: URLSessionWebSocketDelegate {
}

enum NetworkConnectionMode: String, Hashable, CaseIterable {
    /// Data transmission protocol where the device initiates sending data to the server at set intervals.
    case clientMaster = "Client Master"
    /// Data transmission protocol where the server requests data at set intervals asynchronously.
    case clientSlaveAsync = "Client Slave Async"
    /// Data transmission protocol where the device sends the data synchronously when the server requests for it.
    case clientSlaveSync = "Client Sync Sync"
}
