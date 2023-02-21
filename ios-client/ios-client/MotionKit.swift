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
    
    @Published var maxPositiveXAccelerationDetected = 0
    @Published var maxNegativeXAccelerationDetected = 0
    
    private var xSpeed = 0
    private var ySpeed = 0
    
    private var xSmooth = 0
    private var ySmooth = 0
    
    private var bufferX: [Int] = [0, 0, 0, 0, 0]
    private var bufferY: [Int] = [0, 0, 0, 0, 0]
    
    private var global_i = 0
    
    
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
        
        print("Begin updating accelerometer")
        self.manager.deviceMotionUpdateInterval = 1.0 / 60.0
        self.manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.queue) { [self] data, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let validData = data {
                computeAcceleration(validData.userAcceleration)
//                computeXYCoordinate(validData.userAcceleration)
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
//            Assuming the phone is being held in portrait, screen facing user.
//            let acc_data_x = accelerationData.x * 500
//            let acc_data_y = accelerationData.y * 500
//            let dist_x = getCalibratedCoordinate(acc_data_x)
//            let dist_y = getCalibratedCoordinate(acc_data_y)
//
//            x += Int(dist_x)
//            y += Int(dist_y)
            
            if global_i != 5 {
                bufferX[global_i] = Int(accl_x * 3)
                bufferY[global_i] = Int(accl_y * 3)
                xSmooth = 0
                ySmooth = 0
                global_i = 0
            } else {
                for each_step in 0...4 {
                    bufferX[each_step] = bufferX[each_step + 1]
                    bufferY[each_step] = bufferY[each_step + 1]
                }
                
                bufferX[0] = Int(accl_x * 3)
                bufferY[0] = Int(accl_y * 3)
                
                xSmooth = bufferX.meanInt
                ySmooth = bufferY.meanInt
            }
            
            if maxPositiveXAccelerationDetected < xSmooth {
                maxPositiveXAccelerationDetected = xSmooth;
                xSpeed = maxPositiveXAccelerationDetected;
            } else if xSmooth < 0 {
                maxPositiveXAccelerationDetected -= xSmooth;
            }

            if maxNegativeXAccelerationDetected < ySmooth {
                maxNegativeXAccelerationDetected = ySmooth;
                ySpeed = maxNegativeXAccelerationDetected;
            } else if ySmooth < 0 {
                maxNegativeXAccelerationDetected -= ySmooth;
            }
            
        }
    }
    
    // MARK: getCalibratedCoordinates
    private func getCalibratedCoordinate(_ accData: Double) -> Double {
        var calibratedCoordinate: Double = 0.0
//
//        if accData > (2 * 500) {
//            calibratedCoordinate = 120.0
//        } else if accData < (-2 * 500) {
//            calibratedCoordinate = 0.0
//        }
        
        
//        for (j in 0..4)
//                    {
//                        bufferx[j] = bufferx[j+1];
//                        buffery[j] = buffery[j+1];
//                    }
//                    bufferx[0] = (accX*3).toInt();
//                    buffery[0] = (accY*3).toInt();
//
//                    xsmooth = (bufferx[0] + bufferx[1] + bufferx[2] + bufferx[3] + bufferx[4]) / 5;
//                    ysmooth = (buffery[0] + buffery[1] + buffery[2] + buffery[3] + buffery[4]) / 5;

        if global_i != 5 {
            bufferX[global_i] = Int(accl_x * 3)
            bufferY[global_i] = Int(accl_y * 3)
            xSmooth = 0
            ySmooth = 0
            global_i = 0
        } else {
            for each_step in 0...4 {
                bufferX[each_step] = bufferX[each_step + 1]
                bufferY[each_step] = bufferY[each_step + 1]
            }
            
            bufferX[0] = Int(accl_x * 3)
            bufferY[0] = Int(accl_y * 3)
            
            xSmooth = bufferX.meanInt
            ySmooth = bufferY.meanInt
//            xSmooth = bufferX.reduce(0, +) / bufferX.count
//            ySmooth = bufferY.reduce(0, +) / bufferY.count
        }
        return calibratedCoordinate
    }
}
