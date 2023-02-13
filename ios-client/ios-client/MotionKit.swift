//
//  MotionKit.swift
//  ios-client
//
//  Created by Praanto on 2023-02-12.
//

import Foundation
import CoreMotion


/// `MotionKit` class is responsible for retrieving, storing and processing sensor data in this project.
///
/// `MotionKit` translates accelerometer data from an iOS device into 
/// game commands for the u32 system.
class MotionKit: ObservableObject {
    
    /// Contains `x` and `y` coordinate of the next position of the paddle on the OLED display.
    @Published var latestCoordinate = MKCoordinate()
    
    // MARK: Published variables
    @Published var accl_x   = 0.0
    @Published var accl_y   = 0.0
    @Published var accl_z   = 0.0
    
    @Published var tilt_x   = 0
    @Published var tilt_y   = 0
    @Published var tilt_z   = 0
    
    @Published var x = 0 {
        didSet {
            if self.x > 120 { self.x = 120 }
            if self.x > 0 { self.x = 0 }
        }
    }
    @Published var y = 0 {
        didSet {
            if self.y > 30 { self.y = 30 }
            if self.y < 0 { self.y = 0 }
        }
    }
    
    @Published var speed    = 0
    
    
    private var queue       = OperationQueue()
    private var manager     = CMMotionManager()
    
    /// Starts updating values in ``latestCoordinate``.
    func startUpdatingCoordinates() throws {
        if !manager.isAccelerometerAvailable {
            throw AccelerometerNotAvailableError()
        }
        
        if !manager.isGyroAvailable {
            throw GyroNotAvailableError()
        }
        
        self.manager.deviceMotionUpdateInterval = 1.0 / 60.0
        self.manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.queue) { [self] data, error in
            if let validData = data {
                computeAcceleration(validData.userAcceleration)
                computeXYCoordinate(validData.userAcceleration)
            }
        }
        
        self.manager.startGyroUpdates(to: self.queue) { [self] data, error in
            if let data = data {
                computeTilt(data)
            }
        }
    }
    
    /// Ends updating values in ``latestCoordinate``.
    func endUpdatingCoordinates() {
        self.manager.stopAccelerometerUpdates()
        self.manager.stopDeviceMotionUpdates()
        self.manager.stopGyroUpdates()
    }
    
    // MARK: Sensor Data Comp Funcs
    private func computeAcceleration(_ accelerationData: CMAcceleration) {
        DispatchQueue.main.async {
            self.accl_x = accelerationData.x
            self.accl_y = accelerationData.y
            self.accl_z = accelerationData.z
        }
    }
    
    private func computeTilt(_ tiltData: CMGyroData) {
        DispatchQueue.main.async {
            self.tilt_x = Int(tiltData.rotationRate.x)
            self.tilt_y = Int(tiltData.rotationRate.y)
            self.tilt_z = Int(tiltData.rotationRate.z)
        }
    }
    
    // MARK: computeXYCoordinate
    private func computeXYCoordinate(_ accelerationData: CMAcceleration) {
        DispatchQueue.main.async { [self] in
            // Assuming the phone is being held in portrait, screen facing user.
            let acc_data_x = accelerationData.x * 500
            let acc_data_y = accelerationData.y * 500
            let dist_x = getCalibratedCoordinate(acc_data_x)
            let dist_y = getCalibratedCoordinate(acc_data_y)
            
            x += Int(dist_x)
            y += Int(dist_y)
        }
    }
    
    // MARK: getCalibratedCoordinates
    private func getCalibratedCoordinate(_ accData: Double) -> Double {
        var calibratedCoordinate: Double = 0.0
        
        if accData > (2 * 500) {
            calibratedCoordinate = 120.0
        } else if accData < (-2 * 500) {
            calibratedCoordinate = 0.0
        }
        
        if abs(accData) > 10 {
            calibratedCoordinate = 1.0 * accData.signOf()
        } else if abs(accData) > 20 {
            calibratedCoordinate = 2.0 * accData.signOf()
        } else if abs(accData) > 30 {
            calibratedCoordinate = 3.0 * accData.signOf()
        }
        
        return calibratedCoordinate
    }
    
}

/// Encapsulates the x and y coordinate of the user's racquet while also ensuring that the coordinates do not go out of display bounds.
class MKCoordinate {
    var x: Double = 0.0 {
        didSet {
            
        }
    }
    var y: Double = 0.0 {
        didSet {
            
        }
    }
    
    
}

class AccelerometerNotAvailableError: Error {
    
}


class GyroNotAvailableError: Error {
    
}

extension Double {
    func signOf() -> Int {
        return self > 0 ? 1 : -1
    }
    
    func signOf() -> Double {
        return self > 0 ? 1.0 : -1.0
    }
}
