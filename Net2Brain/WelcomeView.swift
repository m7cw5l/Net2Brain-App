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
        
    @State var pipelineParameters = PipelineParameters()
    @StateObject var pipelineData = PipelineData()
    
    @State private var path = NavigationPath()
            
    let explanations = [
        Explanation(title: "explanation.main.roi.title", description: "explanation.main.roi", show: false),
        Explanation(title: "explanation.main.fmri.title", description: "explanation.main.fmri", show: false),
        Explanation(title: "explanation.main.compare.data.title", description: "explanation.main.compare.data", show: false),
        Explanation(title: "explanation.main.data.generation.title", description: "explanation.main.data.generation", show: false),
        Explanation(title: "explanation.main.images.title", description: "explanation.main.images", show: false)
    ]
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
    
    var body: some View {
        NavigationStack(path: $path) {
                List {
                    Section {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(menuItems, id: \.title) { menuItem in
                                Button(action: {
                                    path.append(menuItem.targetView)
                                }, label: {
                                    WelcomeGridItemView(icon: menuItem.systemIcon, title: menuItem.title)
                                }).buttonStyle(BorderlessButtonStyle())
                            }
                        }.background(Color(uiColor: .systemGroupedBackground))
                            .listRowInsets(EdgeInsets())
                    }
                    Section {
                        NavigationLink(value: MenuTargetView.history, label: {
                            Label("mainmenu.history.title", systemImage: "clock.fill")
                        })
                    }
                    
                    Section("explanation.menu.title") {
                        ForEach(explanations, id: \.title) { explanation in
                            ExplanationRow(title: explanation.title, description: explanation.description, currentExplanation: $currentExplanation)
                        }
                    }
                }.background(Color(uiColor: UIColor.secondarySystemBackground))
                .navigationTitle(String(localized: "view.main.title"))
                .navigationDestination(for: MenuTargetView.self, destination: { targetView in
                    // Navigation Destinations for Main Menu
                    switch targetView {
                    case .visualizeRoi:
                        VisualizeRoiView(path: $path)
                    case .visualizeFmri:
                        VisualizeRoiImageView(path: $path)
                    case .prediction:
                        SelectDatasetView(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
                    case .imageOverview:
                        ImagesOverviewView(path: $path)
                    case .history:
                        HistoryOverview(path: $path)
                    }
                })
                .navigationDestination(for: PipelineView.self, destination: { selection in
                    // navigation Destinations for Prediction Pipeline
                    switch selection {
                    case .datasetImages:
                        SelectDatasetImagesView(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
                    case .mlModel:
                        SelectMLModelView(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
                    case .mlLayers:
                        SelectMLLayersView(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
                    case .rdmMetric:
                        SelectRDMMetricView(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
                    case .evaluationType:
                        SelectEvaluationTypeView(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
                    case .rsaChart:
                        RSAChartView(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
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
