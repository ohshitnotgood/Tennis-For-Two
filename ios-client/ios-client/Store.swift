//
//  Store.swift
//  ios-client
//
//
//  This file contains store class declarations.
//
//  A store class is any ObservableObject that is passed between views as an EnvironmentObject.
//
//  Created by Praanto on 2023-02-16.
//

import Foundation
import Network

/// Stores settings data for the app.
class SettingsValueStore: ObservableObject {
    @Published var sensorDataRefreshRate = 100.0
    @Published var connectionStatus = "Disconnected"
    @Published var sensitivity = 6
    @Published var boardIPAddress = ""
    
    /// Establishes connection to and starts listening for data from the board.
    func connectToBoard() async throws {
        guard let url = URL(string: boardIPAddress) else {
            throw ConnectionEstablishmentFailedError.InvalidAddress
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard let response = response as? HTTPURLResponse else {
            return
        }
    }
    
    func startListening() {
        
    }
    
    /// Stops listening for data from the board.
    func disconnectFromBoard() async {
        
    }
}

/// Handles ports on the iOS client
///
/// This class is capable of opening ports on the iOS client.
///
/// **Acknowledgement**:
///
/// This class was originally written by github/@michael94ellis.
///
/// Find his original work here: 
class UDPListener: ObservableObject {
    private let networkParameter = NWParameters.udp
    
    private let listener: NWListener
    
    init() throws {
        listener = try NWListener(using: networkParameter)
    }
}
