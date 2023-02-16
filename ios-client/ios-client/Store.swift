//
//  Store.swift
//  ios-client
//
//
//  This file contains store class declarations.
//
//  A store class is any ObservableObject that is passed between views as an EnvironmentObject.
//
//  Created by Praanto on 2023-02-16.
//

import Foundation

/// Stores settings data for the app.
class SettingsValueStore: ObservableObject {
    @Published var sensorDataRefreshRate = 100.0
    @Published var connectionStatus = "Disconnected"
    @Published var sensitivity = 6
    @Published var boardIPAddress = ""
}
