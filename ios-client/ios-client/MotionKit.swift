//
//  MotionKit.swift
//  ios-client
//
//  Created by Praanto on 2023-02-12.
//

import Foundation
import CoreMotion
import Logging


/// `MotionKit` class is responsible for retrieving, storing and processing sensor data in this project.
///
/// `MotionKit` translates accelerometer data from an iOS device into 
/// game commands for the u32 system.
class MotionKit: ObservableObject {
    
    // MARK: Published variables
    @Published var user_accl_x   = 0.0
    @Published var user_accl_y   = 0.0
    @Published var user_accl_z   = 0.0
    
    @Published var raw_accl_x    = 0.0
    @Published var raw_accl_y    = 0.0
    @Published var raw_accl_z    = 0.0
    
    @Published var tilt_x        = 0
    @Published var tilt_y        = 0
    @Published var tilt_z        = 0
    
    @Published var x = 0 {
        didSet {
            if self.x > 120 { self.x = 120 }
            if self.x > 0 { self.x = 0 }
        }
    }
    @Published var y = 0 {
        didSet {
            if self.y > 300 { self.y = 30 }
            if self.y < 0 { self.y = 0 }
        }
    }
    
    @Published var speed    = 0
    
    @Published var max_pos_user_accl_y = -10000000
    @Published var max_neg_user_accl_y =  10000000
    
    @Published var max_pos_raw_accl_y  = -10000000
    @Published var max_neg_raw_accl_y  =  10000000
    
    private var queue       = OperationQueue()
    private var manager     = CMMotionManager()
    private var logger      = Logger(label: Logger.TAG_MOTION_KIT)
    
    private var userAcceleration: CMAcceleration? = nil
    private var rawAcceleration: CMAcceleration? = nil
    
    private let dispatchQueue = DispatchQueue.main
    
    private var buffer_user_x: [Double] = []
    private var buffer_user_y: [Double] = []
    
    private var buffer_raw_x: [Double] = []
    private var buffer_raw_y: [Double] = []
    
    private var didInitialDecelerationFinish = false
    
    /// Starts updating values in ``latestCoordinate``.
    func startUpdatingCoordinates() throws {
        if !manager.isAccelerometerAvailable {
            logger.error("Accelerometer not available.")
            throw AccelerometerNotAvailableError()
        }
        
        if !manager.isGyroAvailable {
            logger.error("Gyroscope is not available.")
            throw GyroNotAvailableError()
        }
        
        logger.info("Starting fetching accelerometer data")
        self.manager.showsDeviceMovementDisplay = true
        self.manager.deviceMotionUpdateInterval = 10.0 / 60.0
        self.manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.queue) { [self] data, error in
            if let error = error {
                logger.error("\(error.localizedDescription)")
                return
            }
            if let motionData = data {
                computeUserAcceleration(motionData.userAcceleration)
                
//                guard let rawAcceleration = self.manager.accelerometerData?.acceleration else {
//                    logger.error("Cannot get raw acceleration data this way.")
//                    return
//                }
                if let rawAcceleration = self.manager.accelerometerData?.acceleration {
                    computeXYCoordinate(raw: rawAcceleration, user: motionData.userAcceleration)
                } else {
                    logger.error("Could not get raw accelerometer data")
                }
                calculateMaximumUserYAccl(motionData.userAcceleration)
            }
        }
        
        logger.info("Starting calculating raw accelerometer data.")
        self.manager.accelerometerUpdateInterval = 1.0 / 60.0
        self.manager.startAccelerometerUpdates(to: self.queue) { data, error in
            self.rawAcceleration = data?.acceleration
            if let rawData = data {
                self.computeRawAcceleration(rawData.acceleration)
                self.calculateMaximumRawYAccl(rawData.acceleration)
            }
        }

        logger.info("Starting gyroscope update")
        self.manager.startGyroUpdates(to: self.queue) { [self] data, error in
            if let data = data {
                computeTilt(data)
            }
        }
    }
    
    /// Ends updating values in ``latestCoordinate``.
    func endUpdatingCoordinates() {
        logger.info("Stopping updating coordinate.")
        self.manager.stopAccelerometerUpdates()
        self.manager.stopDeviceMotionUpdates()
        self.manager.stopGyroUpdates()
    }
    
    // MARK: Sensor Data Comp Funcs
    private func computeUserAcceleration(_ accelerationData: CMAcceleration) {
        dispatchQueue.async {
            self.user_accl_x = accelerationData.x
            self.user_accl_y = accelerationData.y
            self.user_accl_z = accelerationData.z
            
            if self.x > self.max_pos_user_accl_y {
                self.max_pos_user_accl_y = self.x
            }
            
            self.buffer_user_x.append(element: accelerationData.x)
            self.buffer_user_y.append(element: accelerationData.y)
        }
    }
    
    private func computeRawAcceleration(_ accelerationData: CMAcceleration) {
        dispatchQueue.async {
            self.raw_accl_x = accelerationData.x
            self.raw_accl_y = accelerationData.y
            self.raw_accl_z = accelerationData.z
            
            self.buffer_raw_x.append(element: accelerationData.x)
            self.buffer_raw_y.append(element: accelerationData.y)
        }
    }
    
    private func computeTilt(_ tiltData: CMGyroData) {
        dispatchQueue.async {
            self.tilt_x = Int(tiltData.rotationRate.x)
            self.tilt_y = Int(tiltData.rotationRate.y)
            self.tilt_z = Int(tiltData.rotationRate.z)
        }
    }
    
    // MARK: computeXYCoordinate
    private func computeXYCoordinate(raw rawAccelerationData: CMAcceleration, user userAccelerationData: CMAcceleration) {
        dispatchQueue.async { [self] in
//            if Int(rawAccelerationData.y * 100).signum() == Int(userAccelerationData.y * 100).signum() {
//                y += Int(userAccelerationData.y * 100)
//            }
            
//            if !didInitialDecelerationFinish {
//                y += abs(Int(userAccelerationData.x * 100))
//            }
            
//            if buffer_user_y.isIncreasing {
//                didInitialDecelerationFinish = true
//            }
//
//            if buffer_user_y.isDecreasing {
//                didInitialDecelerationFinish = false
//            }
            
            if buffer_user_y.isDecreasing && userAccelerationData.y < 0 {
                y += abs(Int(userAccelerationData.y * 10))
                return
            }
            
            y += Int(userAccelerationData.y * 10)
        }
    }
    
    private func calculateMaximumUserYAccl(_ accelerationData: CMAcceleration) {
        dispatchQueue.async {
            if Int(accelerationData.y * 100) > self.max_pos_user_accl_y {
                self.max_pos_user_accl_y = Int(accelerationData.y * 100)
            }
            
            if Int(accelerationData.y * 100) < self.max_neg_user_accl_y {
                self.max_neg_user_accl_y = Int(accelerationData.y * 100)
            }
        }
    }
    
    private func calculateMaximumRawYAccl(_ accelerationData: CMAcceleration) {
        dispatchQueue.async {
            if Int(accelerationData.y * 100) > self.max_pos_user_accl_y {
                self.max_pos_raw_accl_y = Int(accelerationData.y * 100)
            }
            
            if Int(accelerationData.y * 100) < self.max_neg_user_accl_y {
                self.max_neg_raw_accl_y = Int(accelerationData.y * 100)
            }
        }
    }
}
