//
//  WelcomeView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI

struct WelcomeView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var showAboutScreen = false
    
    @State private var selectedTargetView: MenuTargetView?
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
    
    var body: some View {
        NavigationStack {
                List {
                    Section {
                        LazyVGrid(columns: columns, spacing: 8) {
                            WelcomeGridItemView(icon: "brain.head.profile", title: "mainmenu.menu.roi.visualize").onTapGesture {
                                selectedTargetView = .visualizeRoi
                            }
                            WelcomeGridItemView(icon: "doc.text.image", title: "mainmenu.menu.fmri.visualize").onTapGesture {
                                selectedTargetView = .visualizeRoiImage
                            }
                            WelcomeGridItemView(icon: "chart.bar.xaxis", title: "mainmenu.menu.predict").onTapGesture {
                                selectedTargetView = .modelAccuracy
                            }
                            WelcomeGridItemView(icon: "photo.on.rectangle.angled", title: "mainmenu.menu.images").onTapGesture {
                                selectedTargetView = .imageOverview
                            }
                        }.background(Color(uiColor: .systemGroupedBackground))
                            .listRowInsets(EdgeInsets())
                    }
                    
                    Section("explanation.menu.title") {
                        /// https://stackoverflow.com/a/68346724 ; 04.01.24 12:23
                        ExplanationButton(title: "explanation.main.roi.title", description: "explanation.main.roi", currentExplanation: $currentExplanation)
                        ExplanationButton(title: "explanation.main.fmri.title", description: "explanation.main.fmri", currentExplanation: $currentExplanation)
                        ExplanationButton(title: "explanation.main.compare.data.title", description: "explanation.main.compare.data", currentExplanation: $currentExplanation)
                        ExplanationButton(title: "explanation.main.data.generation.title", description: "explanation.main.data.generation", currentExplanation: $currentExplanation)
                        ExplanationButton(title: "explanation.main.images.title", description: "explanation.main.images", currentExplanation: $currentExplanation)
                    }
                }.background(Color(uiColor: UIColor.secondarySystemBackground))
                .navigationTitle(String(localized: "view.main.title"))
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
                    Button(String(localized: "mainmenu.about.button.title"), systemImage: "info.circle") {
                        showAboutScreen.toggle()
                    }
                }.sheet(isPresented: $showAboutScreen) {
                    AboutAppView()
                }.sheet(isPresented: $currentExplanation.show) {
                    /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
                    ExplanationSheet(sheetTitle: $currentExplanation.title, sheetDescription: $currentExplanation.description)
                }
        }
    }
}

#Preview {
    WelcomeView()
}
