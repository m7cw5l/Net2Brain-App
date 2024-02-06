//
//  Net2BrainApp.swift
//  Net2Brain
//
//  Created by Marco Weßel on 18.09.23.
//

import SwiftUI

@main
struct Net2BrainApp: App {
    var body: some Scene {
        WindowGroup {
            //WelcomeListView()
            WelcomeView()
        }.modelContainer(for: HistoryEntry.self)
    }
}
