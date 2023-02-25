//
//  Extensions.swift
//  ios-client
//
//  Created by Praanto on 2023-02-16.
//


import SwiftUI

extension Double {
    func signOf() -> Int {
        return self > 0 ? 1 : -1
    }
    
    func signOf() -> Double {
        return self > 0 ? 1.0 : -1.0
    }
}

extension Array where Element == Int {
    var mean: Double {
        Double((self.reduce(0, +) / self.count))
    }
    
    var meanInt: Int {
        Int((self.reduce(0, +) / self.count))
    }
}

extension DispatchQueue {
    static let NETWORK_SOCKET                   = "ws-network-background-0x000010A"
    static let DEVICE_SENSOR_UPDATE             = "device-sensor-update-main-0x000010B"
}

extension NetworkKit {
    enum InitialHandshake: String {
        case clientSlaveSync                    = "0x001"
        case clientSlaveAsync                   = "0x002"
        case clientMaster                       = "0x003"
        case acknowledgementClientSlaveSync     = "0x004"
        case acknowledgementClientSlaveAsync    = "0x005"
        case acknowledgementClientMaster        = "0x006"
        
        case serverError                        = "0xFFB"
    }
    
    enum TransmissionRequest: String {
        case initClientSlaveSync                = "0x101"
        case initClientSlaveAsync               = "0x102"
        case initClientMaster                   = "0x103"
        case killClientSlaveSync                = "0x104"
        case killClientSlaveAsync               = "0x105"
        case killClientSlaveMaster              = "0x106"
    }
    
    enum ClientSlaveSyncProtocolMessage: String {
        case dataRequestFromServer              = "0x200"
    }
    
    enum ClientSlaveAsyncProtocolMessage: String {
        case dataRequestFromServer              = "0x300"
    }
    
    enum ClientMasterProtocolMessage: String {
        case dataSendToServer                   = "0x400"
    }
}
