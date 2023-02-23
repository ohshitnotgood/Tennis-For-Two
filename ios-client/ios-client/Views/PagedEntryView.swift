//
//  PagedEntryView.swift
//  ios-client
//
//  Created by Praanto on 2023-02-23.
//

import SwiftUI

struct PagedEntryView: View {
    var body: some View {
        NavigationView {
            TabView {
                NetworkSettingsView()
                
                VStack {
                    Text("Hej alla!")
                }
            }.tabViewStyle(.page)
        }
    }
}

struct PagedEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PagedEntryView()
    }
}
