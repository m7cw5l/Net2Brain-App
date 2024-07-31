//
//  AboutAppView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 24.10.23.
//

import SwiftUI

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var releaseVersionString: String {
        return "\(releaseVersionNumber ?? "1.0.0")"
    }
    
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    var buildVersionString: String {
        return "\(buildVersionNumber ?? "1")"
    }
}

/// view for displaying info about the app like current version, build, etc.
struct AboutAppView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: {
                        LibraryLicensesView()
                    }, label: {
                        HStack {
                            Image(systemName: "rosette").foregroundStyle(.accent)
                            Text("about.list.libraries.title")
                        }
                    })
                } header: {
                    VStack {
                        HStack {
                            Spacer()
                            Image("app-icon-info-screen").frame(width: 80, height: 80)
                            Spacer()
                        }
                        Text("about.list.version.title.\(Bundle.main.releaseVersionString)").font(.subheadline)
                        Text("about.list.build.title.\(Bundle.main.buildVersionString)")
                        Spacer().frame(height: 16)
                        Text("about.list.developer.title")
                    }.padding()
                }
                Section("about.list.section.advanced.title") {
                    Text("about.list.cache.size.\(getCacheSize())")
                    Button("about.list.delete.cache.title") {
                        URLCache.shared.removeAllCachedResponses()
                    }
                }
                Section {
                    Button("about.list.reset.db.title") {
                        do {
                            try modelContext.delete(model: HistoryEntry.self)
                        } catch {
                            print("Failed to clear history data")
                        }
                    }
                }
            }
            .navigationTitle("view.about.title")
                //.navigationBarTitleDisplayMode(.large)
                .toolbar {
                    Button("button.dismiss.title", systemImage: "xmark") {
                        dismiss()
                    }
                }
        }
    }
    
    /// get's the size of the app's cache
    /// - Returns: string with cache size in MB
    func getCacheSize() -> String {
        let normalCacheSize = Double(URLCache.shared.currentDiskUsage) / 1024 / 1024
        
        return String(format: "%.3f MB", normalCacheSize)
    }
}

#Preview {
    AboutAppView()
}
