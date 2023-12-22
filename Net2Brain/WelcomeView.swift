//
//  WelcomeView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI

struct WelcomeView: View {
    let data = [
        (title: "Visualize vertices on brain surface map", icon: "brain.head.profile"),
        (title: "Visualize fMRI data with selected image", icon: "doc.text.image"),
        (title: "Predict fMRI response with ML model", icon: "chart.bar.xaxis"),
        (title: "Show available stimulus images", icon: "photo.on.rectangle.angled")
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var showAboutScreen = false
    
    @State private var selectedTargetView: MenuTargetView?
    
    var body: some View {
        NavigationStack {
                List {
                    Section {
                        LazyVGrid(columns: columns, spacing: 8) {
                            WelcomeGridItemView(icon: "brain.head.profile", title: "Visualize vertices on brain surface map").onTapGesture {
                                selectedTargetView = .visualizeRoi
                            }
                            WelcomeGridItemView(icon: "doc.text.image", title: "Visualize fMRI data with selected image").onTapGesture {
                                selectedTargetView = .visualizeRoiImage
                            }
                            WelcomeGridItemView(icon: "chart.bar.xaxis", title: "Predict fMRI response with ML model").onTapGesture {
                                selectedTargetView = .modelAccuracy
                            }
                            WelcomeGridItemView(icon: "photo.on.rectangle.angled", title: "Show available stimulus images").onTapGesture {
                                selectedTargetView = .imageOverview
                            }
                        }.background(Color(uiColor: .systemGroupedBackground))
                            .listRowInsets(EdgeInsets())
                    }
                    
                    Section("How to's and explanations") {
                        NavigationLink("What is fMRI data?") {
                            //HeatmapChartView()
                        }
                        NavigationLink("Why compare brain data with ML models?") {
                            
                        }
                        NavigationLink("How the brain data was generated") {
                            
                        }
                        NavigationLink("What are \"Stimulus images\"?") {
                            
                        }
                    }
                }.background(Color(uiColor: UIColor.secondarySystemBackground))
                .navigationTitle("Welcome")
                .navigationDestination(item: $selectedTargetView, destination: { targetView in
                    switch targetView {
                    case .visualizeRoi:
                        VisualizeRoiView()
                    case .visualizeRoiImage:
                        VisualizeRoiImageView()
                    case .modelAccuracy:
                        SelectDatasetView()
                    case .imageOverview:
                        ImagesOverviewView()
                    }
                })
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
    WelcomeView()
}
