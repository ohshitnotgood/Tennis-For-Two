//
//  ContentView.swift
//  ios-client
//
//  Created by Praanto on 2023-02-12.
//

import SwiftUI

/// Main entry point view of the app.
struct ContentView: View {
    @State private var showCoordinatesHistory   = false
    @State private var showAppLog               = false
    @State private var showCreditsSheet         = false
    
    @StateObject private var kit              = MotionKit()
    
    var body: some View {
        NavigationView {
            VStack {
                LogItemView(
                    messageTitle: "Next coordinates",
                    messageBody: "(x: \(kit.latestCoordinate.x), y: \(kit.latestCoordinate.y))")
                
                
                LogItemView(
                    messageTitle: "Current refresh rate",
                    messageBody: "100Hz")
                
                LogItemView(
                    messageTitle: "Connection status",
                    messageBody: "Disconnected")
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showCoordinatesHistory.toggle()
                        } label: {
                            Label("View coordinates history", systemImage: "graph")
                        }
                        
                        Button("Adjust refresh rate") {
                            
                        }
                        
                        Button("Connect to board") {
                            
                        }
                        
                        Button("Credits") {
                            showCreditsSheet.toggle()
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showCoordinatesHistory, content: {
                CoordinatesListingView()
            })
            .sheet(isPresented: $showCreditsSheet, content: {
                CreditsView()
            })
            .navigationTitle("ios-client")
            .padding()
        }
    }
}

struct LogItemView: View {
    let messageTitle: String
    let messageBody: String
    var body: some View {
        VStack {
            Text(messageTitle)
            Text(messageBody)
                .monospaced()
        }.padding()
    }
}

struct CreditsView: View {
    var body: some View {
        ScrollView {
            Text("Acknowledgements")
                .bold()
                .font(.title)
        }
    }
}

struct CoordinatesListingView: View {
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Text(Date().formatted(date: .abbreviated, time: .complete))
                    Spacer()
                    Text("20.321\n21.3212")
                        .monospaced()
                }
            }.navigationTitle("Coordinates History")
        }
    }
}

@available(*, unavailable)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@available(*, unavailable)
struct CoordinatesListingView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatesListingView()
    }
}
