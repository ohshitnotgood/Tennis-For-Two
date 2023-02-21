//
//  NetworkKit.swift
//  ios-client
//
//  Created by Praanto on 2023-02-16.
//

import Foundation
import Logging

class NetworkKit: NSObject {
    private var socket: URLSessionWebSocketTask? = nil
    private var socketHasBeenEstablished = false
    
    private var shouldContinueListening = false
    
    private let logger = Logger(label: Logger.TAG_WS)
    
    /// Establishes a new websocket connection with the address provided.
    ///
    /// Will throw an error if the address is invalid and cannot be casted to an `URL` object.
    func connectToBoard(_ address: String) async throws {
        logger.info("Connecting to \(address)")
        if let url = URL(string: address) {
            let urlRequest = URLRequest(url: url)
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.socket = urlSession.webSocketTask(with: urlRequest)
            self.socket?.resume()
            logger.info("Connection succeeded.")
            socketHasBeenEstablished = true
        } else {
            throw ConnectionEstablishmentFailedError.InvalidAddress
        }
    }
    
    func pauseConnectionToBoard() async throws {
        if !socketHasBeenEstablished {
            throw ConnectionEstablishmentFailedError.SocketNotEstablished
        }
        
    }
    
    func pauseListening() {
        shouldContinueListening = false
    }
    
    func killConnectionToBoard() async throws {
        if !socketHasBeenEstablished {
            throw ConnectionEstablishmentFailedError.SocketNotEstablished
        }
        
        socketHasBeenEstablished = false
    }
    
    func sendMessage(_ data: String) throws {
//        if !socketHasBeenEstablished {
//            logger.error("Failed to send data. Socket has not been established.")
//            throw ConnectionEstablishmentFailedError.SocketNotEstablished
//        }
        
        logger.info("Sending data: \(data) to websocket server.")
        let message = URLSessionWebSocketTask.Message.string(data)
        socket?.send(message, completionHandler: { error in
            guard let error = error else {
                self.logger.error("Unknown error")
                return
            }
            
            self.logger.error(Logger.Message(stringLiteral: error.localizedDescription))
        })
    }
    
    func ping(_ message: String) {
        socket?.sendPing(pongReceiveHandler: { error in
            
        })
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
                        case .data(let data): self.logger.info("\(data)")
                        case .string(let string): self.logger.info("\(string)")
                        @unknown default: return
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
            }
        })
        
        if shouldContinueListening {
            try startListening()
        }
    }
}

extension NetworkKit: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        socketHasBeenEstablished = true
    }
    
}
