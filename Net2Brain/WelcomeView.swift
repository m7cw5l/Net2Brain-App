//
//  WelcomeView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI

struct MenuItem {
    var systemIcon: String
    var title: String
    var targetView: MenuTargetView
}

struct WelcomeView: View {
    let menuItems = [
        MenuItem(systemIcon: "brain.head.profile", title: "mainmenu.menu.roi.visualize", targetView: .visualizeRoi),
        MenuItem(systemIcon: "doc.text.image", title: "mainmenu.menu.fmri.visualize", targetView: .visualizeFmri),
        MenuItem(systemIcon: "chart.bar.xaxis", title: "mainmenu.menu.predict", targetView: .prediction),
        MenuItem(systemIcon: "photo.on.rectangle.angled", title: "mainmenu.menu.images", targetView: .imageOverview)
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var showAboutScreen = false
    
    @State private var selectedTargetView: MenuTargetView?
    
    let explanations = [
        Explanation(title: "explanation.main.roi.title", description: "explanation.main.roi", show: false),
        Explanation(title: "explanation.main.fmri.title", description: "explanation.main.fmri", show: false),
        Explanation(title: "explanation.main.compare.data.title", description: "explanation.main.compare.data", show: false),
        Explanation(title: "explanation.main.data.generation.title", description: "explanation.main.data.generation", show: false),
        Explanation(title: "explanation.main.images.title", description: "explanation.main.images", show: false)
    ]
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
    
    var body: some View {
        NavigationStack {
                List {
                    Section {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(menuItems, id: \.title) { menuItem in
                                Button(action: {
                                    selectedTargetView = menuItem.targetView
                                }, label: {
                                    WelcomeGridItemView(icon: menuItem.systemIcon, title: menuItem.title)
                                }).buttonStyle(BorderlessButtonStyle())
                                /*.onTapGesture {
                                    selectedTargetView = .visualizeRoi
                                }*/
                            }
                        }.background(Color(uiColor: .systemGroupedBackground))
                            .listRowInsets(EdgeInsets())
                    }
                    
                    Section("explanation.menu.title") {
                        ForEach(explanations, id: \.title) { explanation in
                            ExplanationRow(title: explanation.title, description: explanation.description, currentExplanation: $currentExplanation)
                        }
                    }
                }.background(Color(uiColor: UIColor.secondarySystemBackground))
                .navigationTitle(String(localized: "view.main.title"))
                .navigationDestination(item: $selectedTargetView, destination: { targetView in
                    switch targetView {
                    case .visualizeRoi:
                        VisualizeRoiView()
                    case .visualizeFmri:
                        VisualizeRoiImageView()
                    case .prediction:
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
