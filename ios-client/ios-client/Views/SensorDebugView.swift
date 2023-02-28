//
//  SensorDebugView.swift
//  ios-client
//
//  Created by Praanto on 2023-02-25.
//

import SwiftUI

struct SensorDebugView: View {
    @ObservedObject private var motion = MotionKit()
    
    private let multiplierConst = 100.0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("x_pc\ny_pc")
                            .monospaced()
                        Spacer()
                        Text("\(motion.x)\n\(motion.y)")
                            .monospaced()
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Coordinates")
                }
                
                Section {
                    HStack {
                        Text("x_ax\ny_ax\nz_ax")
                        Spacer()
                        Text("\(motion.user_accl_x)\n\(motion.user_accl_y)\n\(motion.user_accl_z)")
                            .multilineTextAlignment(.trailing)
                            .monospaced()
                    }
                } header: {
                    Text("User Accelerometer Data")
                }
                
                
                Section {
                    HStack {
                        Text("x_ax\ny_ax\nz_ax")
                        Spacer()
                        Text("\(Int(motion.user_accl_x * multiplierConst))\n\(Int(motion.user_accl_y * multiplierConst))\n\(Int(motion.user_accl_z * multiplierConst))")
                            .monospaced()
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("`max_pos_user_accl_y`")
                        Spacer()
                        Text("\(motion.max_pos_user_accl_y)")
                    }
                    
                    HStack {
                        Text("`max_neg_user_accl_y`")
                        Spacer()
                        Text("\(motion.max_neg_user_accl_y)")
                    }
                } header: {
                    Text("Rounded User Accelerometer Data")
                }
                
                Section {
                    HStack {
                        Text("x_ax\ny_ax\nz_ax")
                            .monospaced()
                        
                        Spacer()
                        
                        Text("\(motion.raw_accl_x)\n\(motion.raw_accl_y)\n\(motion.raw_accl_z)")
                            .monospaced()
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Raw Acceleration Data")
                }
                
                Section {
                    HStack {
                        Text("x_ax\ny_ax\nz_ax")
                        Spacer()
                        Text("\(Int(motion.raw_accl_x * multiplierConst))\n\(Int(motion.raw_accl_y * multiplierConst))\n\(Int(motion.raw_accl_z * multiplierConst))")
                            .monospaced()
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("`max_pos_raw_accl_y`")
                        Spacer()
                        Text("\(motion.max_pos_raw_accl_y)")
                    }
                    
                    HStack {
                        Text("`max_neg_raw_accl_y`")
                        Spacer()
                        Text("\(motion.max_neg_raw_accl_y)")
                    }
                } header: {
                    Text("Rounded Raw Acceleration Data")
                }
                
                Section {
                    HStack {
                        Text("x_ax\ny_ax\nz_ax")
                        Spacer()
                        Text("\(motion.tilt_x)\n\(motion.tilt_y)\n\(motion.tilt_z)")
                    }
                    
                } header: {
                    Text("Raw Gyroscope Data")
                }
                
                Section {
                    HStack {
                        Text("x_ax\ny_ax\nz_ax")
                        Spacer()
                        Text("\(Int(motion.tilt_x * multiplierConst))\n\(Int(motion.tilt_y * multiplierConst))\n\(Int(motion.tilt_z * multiplierConst))")
                            .monospaced()
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Rounded Gyroscope Data")
                }
            }.navigationTitle("Sensor Debugger")
                .onAppear {
                    Task {
                        try motion.startUpdatingCoordinates()
                    }
                }.listStyle(.sidebar)
        }
    }
}

struct SensorDebugView_Previews: PreviewProvider {
    static var previews: some View {
        SensorDebugView()
    }
}
