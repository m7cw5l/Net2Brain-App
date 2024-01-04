//
//  SelectMLModelView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI
import Matft

struct SelectMLModelView: View {
    
    @State var selectedHelpItem: String = ""

    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @State var isCalculating = false
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
        
    var body: some View {
        NavigationStack {
            VStack {
                
                PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .mlModel)
                
                Form {
                    Picker("pipeline.available.models.title", selection: $pipelineParameters.mlModel) {
                        ForEach(Array(availableMLModels), id: \.key) { model in
                            VStack(alignment: .leading) {
                                Text(model.name)
                                Text(model.description).font(.caption)
                            }.tag(model)
                        }
                    }.pickerStyle(.inline)
                }
                
                NavigationLink(destination: {
                    SelectMLLayersView(pipelineParameters: pipelineParameters, pipelineData: pipelineData)
                }, label: {
                    Text("button.next.title").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding()
                    .disabled(pipelineParameters.mlModel.name == "")
                
            }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("view.pipeline.model.title")
            .toolbar {
                Menu("explanation.menu.title", systemImage: "questionmark.circle", content: {
                    ExplanationMenuButton(title: "explanation.model.title", description: "explanation.model", currentExplanation: $currentExplanation)
                    ExplanationMenuButton(title: "explanation.model.cnn.title", description: "explanation.model.cnn", currentExplanation: $currentExplanation)
                    ExplanationMenuButton(title: "explanation.model.pytorch.title", description: "explanation.model.pytorch", currentExplanation: $currentExplanation)
                })
            }
            .onChange(of: pipelineParameters.mlModel) {
                pipelineParameters.resetMLModelLayers()
                pipelineData.resetPredictionOutputs()
                pipelineData.resetDistanceMatrices()
            }.sheet(isPresented: $currentExplanation.show) {
                /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
                ExplanationSheet(sheetTitle: $currentExplanation.title, sheetDescription: $currentExplanation.description)
            }
        }
    }
    
    
}

#Preview {
    SelectMLModelView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData())
}
