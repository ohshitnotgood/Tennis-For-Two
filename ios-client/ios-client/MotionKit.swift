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
    
    private var manager = CMMotionManager()
    
    func startUpdatingCoordinates() {
        
    }
    
    func endUpdatingCoordinates() {
        
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


