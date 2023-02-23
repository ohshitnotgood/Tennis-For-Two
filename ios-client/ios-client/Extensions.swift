//
//  Extensions.swift
//  ios-client
//
//  Created by Praanto on 2023-02-16.
//

import Foundation
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
    static let NETWORK_SOCKET           = "ws-network-background-0x000010A"
    static let DEVICE_SENSOR_UPDATE     = "device-sensor-update-main-0x000010B"
}
