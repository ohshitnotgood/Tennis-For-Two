//
//  ios_clientApp.swift
//  ios-client
//
//  Created by Praanto on 2023-02-12.
//

import SwiftUI

@main
struct ios_clientApp: App {
    @ObservedObject private var settings = SettingsValueStore()
    
    var body: some Scene {
        WindowGroup {
            NetworkDebugView()
                .environmentObject(settings)
        }
    }
}
