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
    
    @Binding var path: NavigationPath
        
    @State var isCalculating = false
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
        
    var body: some View {
        VStack {
            
            PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .mlModel)
            
            Form {
                Picker("pipeline.available.models.title", selection: $pipelineParameters.mlModel) {
                    ForEach(Array(availableMLModels), id: \.key) { model in
                        HStack {
                            ExplanationInfoButton(title: model.name, description: model.modelDescription, currentExplanation: $currentExplanation)
                            Text(model.name)
                        }.tag(model)
                    }
                }.pickerStyle(.inline)
            }
            
            Button(action: {
                path.append(PipelineView.mlLayers)
            }, label: {
                Text("button.next.title").frame(maxWidth: .infinity).padding(6)
            }).buttonStyle(BorderedProminentButtonStyle())
                .padding()
                .disabled(pipelineParameters.mlModel.name == "")
            
        }.background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("view.pipeline.model.title")
        .toolbar {
            RestartPipelineButton(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
            Menu("explanation.menu.title", systemImage: "questionmark.circle", content: {
                ExplanationMenuButton(title: "explanation.model.title", description: "explanation.model", currentExplanation: $currentExplanation)
                ExplanationMenuButton(title: "explanation.model.cnn.title", description: "explanation.model.cnn", currentExplanation: $currentExplanation)
                ExplanationMenuButton(title: "explanation.model.pytorch.title", description: "explanation.model.pytorch", currentExplanation: $currentExplanation)
            })
        }
        .onChange(of: pipelineParameters.mlModel) {
            pipelineParameters.resetMLModelLayers()
            pipelineData.resetAll()
        }.sheet(isPresented: $currentExplanation.show) {
            /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
            ExplanationSheet(sheetTitle: $currentExplanation.title, sheetDescription: $currentExplanation.description)
        }
    }
    
    
}

#Preview {
    SelectMLModelView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData(), path: .constant(NavigationPath()))
}
