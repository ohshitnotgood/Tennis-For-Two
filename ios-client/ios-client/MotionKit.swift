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
    var latestCoordinate = MKCoordinate()
    
    private var manager = CMMotionManager()
    private var timer: Timer?
    private var queue = OperationQueue()
    
    /// Starts updating values in ``latestCoordinate``.
    func startUpdatingCoordinates() throws {
        if manager.isAccelerometerAvailable {
            print("Accelerometer is available")
        } else {
            print("Accelerometer not available")
        }
        
        if !manager.isGyroAvailable {
            throw GyroscopeNotAvailableError()
        }
        
        manager.startAccelerometerUpdates()
        
        self.timer = Timer(fire: Date(), interval: (1.0 / 60.0), repeats: true,
                           block: { [self] (timer) in
            if let data = self.manager.deviceMotion {
                // Get the attitude relative to the magnetic north reference frame.
                latestCoordinate.computeXYCoordinates(data.attitude)
                latestCoordinate.computeAcceleration(data.userAcceleration)
            }
        })
        
        self.manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: self.queue) { data, error in
            if let data = data {
                self.latestCoordinate.computeXYCoordinates(data.attitude)
                self.latestCoordinate.computeAcceleration(data.userAcceleration)
            }
        }
        
        self.manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: self.queue) { data, error in
            if let data = data {
                self.latestCoordinate.computeXYCoordinates(data.attitude)
                self.latestCoordinate.computeAcceleration(data.userAcceleration)
            }
        }
        
        self.manager.startGyroUpdates(to: self.queue) { data, error in
            if let data = data {
            }
        }
        
        // Add the timer to the current run loop.
        RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
    }
    
    /// Ends updating values in ``latestCoordinate``.
    func endUpdatingCoordinates() {
        
    }
}

/// Encapsulates the `x` and `y` coordinate of the user's racquet while also ensuring that the coordinates do not go out of display bounds.
class MKCoordinate: ObservableObject {
    /// `x` coordinate of the center of the player's racket.
    @Published var x: Int = 0 {
        didSet {
            if self.x > 128 { x = 128}
            else if x < 0 { x = 0 }
        }
    }
    
    /// `y` coordinate of the center of the player's racket.
    @Published var y: Int = 0 {
        didSet {
            if self.y > 32 { self.y = 32 }
            else if self.y < 0 { self.y = 0 }
        }
    }
    
    /// Acceleration of the player's racket.
    var acceleration = 0 {
        didSet {
            
        }
    }
    
    #if DEBUG
    @Published var roll     = 0
    @Published var pitch    = 0
    @Published var yaw      = 0
    @Published var gyro_x   = 0
    @Published var gyro_y   = 0
    @Published var gyro_z   = 0
    @Published var tilt_x   = 0
    @Published var tilt_y   = 0
    @Published var tilt_z   = 0
    #endif
    
    /// Offset between the top and the bottom center pixel of the racket.
    ///
    /// If `tilt` is set to `2`, this means that the pixel at the top of the racket is four units to the right of the pixel at the bottom of the racket.
    ///
    /// This means that if the tilt is `0`, the racket is completely vertical.
    ///
    /// **Validations:**
    ///
    /// Tilt cannot be greater than 10 since the racket is 10 pixels long.
    var tilt = 0 {
        didSet {
            if self.tilt > 10 { tilt = 10 }
            else if self.tilt < 0 { tilt = 0 }
        }
    }
    
    var time = Date()
    
    /// Extracts raw gyroscope data, then translates and writes to ``x`` and ``y``.
    fileprivate func computeXYCoordinates(_ attitude: CMAttitude) {
        pitch = Int(attitude.pitch * 100)
        roll = Int(attitude.roll * 100)
        yaw = Int(attitude.yaw * 100)
        
        print("Attitude Pitch    : \(Int(attitude.pitch * 100))")
        print("Attitude Roll     : \(Int(attitude.roll) * 100)")
        print("Attitude Yaw      : \(Int(attitude.yaw) * 100)")
    }
    
    
    /// Extracts raw acceleration data, then translates and writes to ``acceleration``.
    fileprivate func computeAcceleration(_ accelerationData: CMAcceleration) {
        gyro_x = Int(accelerationData.x * 100)
        gyro_y = Int(accelerationData.y * 100)
        gyro_z = Int(accelerationData.z * 100)
        
        print("AccelerationData X: \(Int(accelerationData.x * 100))")
        print("AccelerationData Y: \(Int(accelerationData.y * 100))")
        print("AccelerationData Z: \(Int(accelerationData.z * 100))")
    }
    
    /// Extracts raw gyro data, then translates nad writes to ``tilt``.
    fileprivate func computeTilt(_ tiltData: CMGyroData) {
        tilt_x = Int(tiltData.rotationRate.x)
        tilt_y = Int(tiltData.rotationRate.y)
        tilt_z = Int(tiltData.rotationRate.z)
        
        print("GyroData RotationRate X: \(Int(tiltData.rotationRate.x))")
        print("GyroData RotationRate Y: \(Int(tiltData.rotationRate.y))")
        print("GyroData RotationRate Z: \(Int(tiltData.rotationRate.z))")
    }
    
}

/// # Errors
class AcceleratometerNotAvailableError: Error {
    
}

class GyroscopeNotAvailableError: Error {
    
}


