//
//  Errors.swift
//  ios-client
//
//  Created by Praanto on 2023-02-16.
//

import Foundation

/// Error thown when tried to run this app on a device that does not have an accelerometer.
class AccelerometerNotAvailableError: Error {
    
}

/// Error thown when tried to run this app on a device that does not have a gyroscope.
class GyroNotAvailableError: Error {
    
}

/// Error thrown when the device fails to establish connection with the WiFi board
enum ConnectionFailedError: Error {
    case IPAddressNotDefined
    case InvalidAddress
    case SocketNotEstablished
    case AddressNotInWebSocketFormat
}

