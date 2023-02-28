//
//  Extensions.swift
//  ios-client
//
//  Created by Praanto on 2023-02-16.
//


import SwiftUI

extension Double {
    func signOf() -> Int {
        return self > 0.0 ? 1 : -1
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

extension Array where Element == Double {
    var isIncreasing: Bool {
        if self.count < 2 {
            return false
        }
        
        if self[self.endIndex - 1] > self[self.endIndex - 2] {
            return true
        }
        
        return false
    }
    
    var isDecreasing: Bool {
        if self.count < 2 {
            return false
        }
        
        if self[self.endIndex - 1] < self[self.endIndex - 2] {
            return true
        }
        
        return false
    }
    
    mutating func append(element: Element) {
        if self.count >= 10 {
            self.removeFirst()
        }
        self.append(element)
    }
}

extension DispatchQueue {
    static let NETWORK_SOCKET                   = "ws-network-background-0x000010A"
    static let DEVICE_SENSOR_UPDATE             = "device-sensor-update-main-0x000010B"
}

extension NetworkKit {
    enum InitialHandshake: String, CaseIterable {
        case clientSlaveSync                    = "0x001"
        case clientSlaveAsync                   = "0x002"
        case clientMaster                       = "0x003"
        case acknowledgementClientSlaveSync     = "0x004"
        case acknowledgementClientSlaveAsync    = "0x005"
        case acknowledgementClientMaster        = "0x006"
        
        case serverError                        = "0xFFB"
    }
    
    enum TransmissionRequest: String, CaseIterable {
        case initClientSlaveSync                = "0x101"
        case initClientSlaveAsync               = "0x102"
        case initClientMaster                   = "0x103"
        case killClientSlaveSync                = "0x104"
        case killClientSlaveAsync               = "0x105"
        case killClientSlaveMaster              = "0x106"
        
        case waitingForPlayerOneToJoin          = "0x107"
    }
    
    enum ClientSlaveSyncProtocolMessage: String, CaseIterable {
        case dataRequestFromServer              = "0x200"
        case dataRequestWithHapticLevelOne      = "0x201"
        case dataRequestWithHapticLevelTwo      = "0x202"
        case dataRequestWithHapticLevelThree    = "0x203"
        case dataRequestWithHapticLevelFour     = "0x204"
    }
    
    enum ClientSlaveAsyncProtocolMessage: String {
        case dataRequestFromServer              = "0x300"
    }
    
    enum ClientMasterProtocolMessage: String {
        case dataSendToServer                   = "0x400"
    }
}
extension String {
    
    /// **Acknowledgement**
    ///
    /// This extension was provided by: https://stackoverflow.com/a/46133083/13727105
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    
    
    /// **Acknowledgement**
    ///
    /// This extension was provided by: https://stackoverflow.com/a/46133083/13727105
    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
