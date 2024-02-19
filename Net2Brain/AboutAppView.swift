//
//  AboutAppView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 24.10.23.
//

import SwiftUI

struct AboutAppView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("about.list.developer.title")
                }
                
                Text("about.list.cache.size.\(getCacheSize())")
                Button("about.list.reset.db.title") {
                    do {
                        try modelContext.delete(model: HistoryEntry.self)
                    } catch {
                        print("Failed to clear history data")
                    }
                }
            }.navigationTitle("view.about.title")
                //.navigationBarTitleDisplayMode(.large)
                .toolbar {
                    Button("button.dismiss.title", systemImage: "xmark") {
                        dismiss()
                    }
                }
        }
    }
    
    func getCacheSize() -> String {
        let normalCacheSize = Double(URLCache.shared.currentDiskUsage) / 1024 / 1024
        //var totalCache = 0.0
        //print("\(Double(URLCache.shared.currentDiskUsage) / 1024 / 1024) MB")
        
        return String(format: "%.3f MB", normalCacheSize)
        //return normalCacheSize
    }
}

#Preview {
    AboutAppView()
}
