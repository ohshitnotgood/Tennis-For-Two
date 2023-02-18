//
//  NetworkKit.swift
//  ios-client
//
//  Created by Praanto on 2023-02-16.
//

import Foundation

class NetworkKit: NSObject {
    private var socket: URLSessionWebSocketTask? = nil
    private var socketHasBeenEstablished = false
    
    
    func connectToBoard(_ address: String) async throws {
        if let url = URL(string: address) {
            let urlRequest = URLRequest(url: url)
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.socket = urlSession.webSocketTask(with: urlRequest)
            self.socket?.resume()
        } else {
            throw ConnectionEstablishmentFailedError.InvalidAddress
        }
    }
    
    func pauseConnectionToBoard() async throws {
        if !socketHasBeenEstablished {
            throw ConnectionEstablishmentFailedError.SocketNotEstablished
        }
        
    }
    
    func killConnectionToBoard() async throws {
        if !socketHasBeenEstablished {
            throw ConnectionEstablishmentFailedError.SocketNotEstablished
        }
        
        
        socketHasBeenEstablished = false
    }
    
    func send(_ data: String) {
        let message = URLSessionWebSocketTask.Message.string(data)
    }
    
    func onReceiveData(callback: () -> ()) {
        callback()
    }
}

extension NetworkKit: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        socketHasBeenEstablished = true
    }
    
}
