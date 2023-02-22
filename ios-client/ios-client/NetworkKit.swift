//
//  NetworkKit.swift
//  ios-client
//
//  Created by Praanto on 2023-02-16.
//

import Foundation
import Logging
import Starscream
import SwiftUI

/// Handles sending and receiving websocket data in this project.
class NetworkKit: NSObject, ObservableObject {
    private var socket: URLSessionWebSocketTask? = nil
    
    private let logger = Logger(label: Logger.TAG_WS)
    private let operationQueue = OperationQueue()
    
    @Published var socketHasBeenEstablished = false
    
    /// Establishes a new websocket connection with the address provided.
    ///
    /// Will throw an error if the address is invalid and cannot be casted to an `URL` object.
    func connectToServer(_ address: String) throws {
        logger.info("Connecting to \(address)")
        if let url = URL(string: address) {
            DispatchQueue.main.async {
                let urlRequest = URLRequest(url: url)
                let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: self.operationQueue)
                self.socket = urlSession.webSocketTask(with: urlRequest)
                self.socket?.maximumMessageSize = 10_000_0000
                self.socket?.resume()
                self.socketHasBeenEstablished = true
                self.logger.info("Connection succeeded: \(self.socketHasBeenEstablished)")
                self.socket?.send(URLSessionWebSocketTask.Message.string("sup alin!"), completionHandler: { error in
                    
                })
            }
        } else {
            throw ConnectionEstablishmentFailedError.InvalidAddress
        }
    }
    
    func connectToServerAsync(_ address: String) async throws {
        logger.info("Connectiong to server at address: \(address)")
        if let url = URL(string: address) {
            let urlRequst = URLRequest(url: url)
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.socket = urlSession.webSocketTask(with: urlRequst)
            try await self.socket?.send(URLSessionWebSocketTask.Message.string("sup world"))
        } else {
            throw ConnectionEstablishmentFailedError.InvalidAddress
        }
    }
    
    /// Sends message to the websocket server after a connection has been established
    ///
    /// Will throw an error if no connection exists.
    func sendMessage(_ data: String) throws {
        socket?.resume()
        logger.info("Sending data: \(data) to websocket server.")
        let message = URLSessionWebSocketTask.Message.string(data)
        
        DispatchQueue.main.async {
            self.socket?.send(message, completionHandler: { error in
                guard let error = error else {
                    self.logger.error("Unknown error")
                    return
                }
                
                self.logger.error(Logger.Message(stringLiteral: error.localizedDescription))
            })
        }
    }
    
    func sendMessageAsync() async throws {
        try await socket?.send(URLSessionWebSocketTask.Message.string("sup world"))
        let response = try await socket?.receive()
        switch response {
            case .data(_): print("")
            case .string(let string): print("Received message: \(string)")
            case .none: print("Received no message")
            case .some(_): print("Received unparsable data")
        }
    }
    
    
    /// Starts listening for incoming data from the server.
    ///
    /// Will throw error if device is not connected to any server. Use ``connectToBoard(_:)`` first before calling this function.
    func startListening() throws {
        if !socketHasBeenEstablished {
            throw ConnectionEstablishmentFailedError.SocketNotEstablished
        }
        
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
        
        try startListening()
    }
}

extension NetworkKit: URLSessionWebSocketDelegate {
    func sendData() {
        
    }
}
