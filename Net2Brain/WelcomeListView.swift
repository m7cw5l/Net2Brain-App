//
//  WelcomeListView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 24.10.23.
//

import SwiftUI

struct WelcomeListView: View {
    
    @State private var showAboutScreen = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: VisualizeRoiView(), label: {
                        Label("Visualize vertices on brain surface map", systemImage: "brain.head.profile")
                    })
                    NavigationLink(destination: VisualizeRoiImageView(), label: {
                        Label("Visualize fMRI data with selected image", systemImage: "doc.text.image")
                    })
                    NavigationLink(destination: SelectDatasetView(), label: {
                        Label("Predict fMRI response with ML model", systemImage: "chart.bar.xaxis")
                    })
                    NavigationLink(destination: ImagesOverviewView(), label: {
                        Label("Show available stimulus images", systemImage: "photo.on.rectangle.angled")
                    })
                }
                Section("How to's and explanations") {
                    NavigationLink("What is fMRI data?") {
                        EmptyView()
                    }
                    NavigationLink("Why compare brain data with ML models?") {
                        EmptyView()
                    }
                    NavigationLink("How the brain data was generated") {
                        EmptyView()
                    }
                    NavigationLink("What are \"Stimulus images\"?") {
                        EmptyView()
                    }
                }
            }.navigationTitle("Welcome")
            .toolbar {
                Button("About", systemImage: "info.circle") {
                    showAboutScreen.toggle()
                }
            }.sheet(isPresented: $showAboutScreen) {
                AboutAppView()
            }
        }
    }
}

#Preview {
    WelcomeListView()
}
