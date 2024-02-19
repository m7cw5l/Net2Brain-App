//
//  RSAChartView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 04.12.23.
//

import SwiftUI
import SwiftData

struct RSAChartView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @Binding var path: NavigationPath
        
    //@State var explanation = Explanation(title: "explanation.general.alert.title", description: "explanation.filler", show: false)
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
    
    var body: some View {
        VStack {
            PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .none, allowCollapse: true)
            
            RSAChart(data: pipelineData.allRoisOutput, pipelineParameters: pipelineParameters)
            
            /*Button("explanation.general.button.title", systemImage: "questionmark.circle", action: {
                explanation.show.toggle()
            })//.padding([.top])*/
            
            Button(action: {
                path = NavigationPath()
                pipelineParameters.resetAll()
                pipelineData.resetAll()
            }, label: {
                Text("button.back.menu.title")
                .frame(maxWidth: .infinity).padding(6)
            }).buttonStyle(BorderedButtonStyle())
                .padding()
            
        }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("view.pipeline.evaluation.chart.title")
            .toolbar {
                RestartPipelineButton(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
                Menu("explanation.menu.title", systemImage: "questionmark.circle", content: {
                    ExplanationMenuButton(buttonTitle: "explanation.general.button.title", title: "explanation.general.alert.title", description: "explanation.filler", currentExplanation: $currentExplanation)
                })
            }
            .sheet(isPresented: $currentExplanation.show) {
                /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
                ExplanationSheet(sheetTitle: $currentExplanation.title, sheetDescription: $currentExplanation.description)
            }.onAppear {
                let simpleMatrices = pipelineData.distanceMatrices.map { key, value in
                    SimpleMatrix(layerName: key, data: value.toFlattenArray(datatype: Float.self, { $0 }), shape: value.shape)
                }
                
                let newHistoryEntry = HistoryEntry(date: Date(), pipelineParameter: HistoryPipelineParameters(pipelineParameters: pipelineParameters), distanceMatrices: simpleMatrices, roiOutput: pipelineData.allRoisOutput)
                modelContext.insert(newHistoryEntry)
            }
    }
}

#Preview {
    let rois = ["visual", "body", "face", "place", "word", "anatomical"]
    let layers = alexnetLayers.map {
        $0.name
    }
    var exampleData = [RSAOutput]()
    for roi in rois {
        for layer in layers {
            exampleData.append(RSAOutput(roi: roi, layer: layer, model: "AlexNet", r2: Float.random(in: 0...5), significance: Float.random(in: 0...1), sem: Float.random(in: 0...1)))
        }
    }
    return RSAChartView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData(), path: .constant(NavigationPath()))
}
