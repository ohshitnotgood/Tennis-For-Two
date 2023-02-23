//
//  ChildrenViews.swift
//  ios-client
//
//  This file contains view declaration that originate from ContentView.
//
//  Created by Praanto on 2023-02-16.
//

import SwiftUI
import Introspect


struct SensitivitySliderView: View {
    @State private var sensitivity = 0
    @EnvironmentObject private var settings: SettingsValueStore
    var body: some View {
        List {
            Section {
                HStack {
                    Stepper("Sensitivity: \(sensitivity)", value: $settings.sensitivity, in: 0...10)
                }
            } header: {
                Text("Adjust Sensitivity")
            }
        }.navigationTitle("Sensitivity Settings")
    }
}



struct LogItemView: View {
    let messageTitle: String
    let messageBody: String
    var body: some View {
        HStack {
            Text(messageTitle)
            Spacer()
            Text(messageBody)
        }.padding()
    }
}

struct CreditsView: View {
    var body: some View {
        NavigationView {
            VStack {
                
            }.navigationTitle("Acknowledgements")
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
            }
            .listStyle(.grouped)
            .navigationTitle("Coordinates History")
        }
    }
}

@available(*, unavailable)
struct CoordinatesListingView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatesListingView()
            .environmentObject(SettingsValueStore())
    }
}


@available(*, unavailable)
struct SensitivitySliderView_Previews: PreviewProvider {
    static var previews: some View {
        SensitivitySliderView()
            .environmentObject(SettingsValueStore())
    }
}

