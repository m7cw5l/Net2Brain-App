//
//  SelectMLModelView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI
import Matft

struct SelectMLModelView: View {

    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @State var isCalculating = false
        
    var body: some View {
        NavigationStack {
            VStack {
                
                PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .mlModel)
                
                Form {
                    Picker("Available Machine Learning Models", selection: $pipelineParameters.mlModel) {
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
                    Text("Next").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding()
                    .disabled(pipelineParameters.mlModel.name == "")
                
            }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Select ML Model")
            .onChange(of: pipelineParameters.mlModel) {
                pipelineParameters.resetMLModelLayers()
                pipelineData.resetPredictionOutputs()
                pipelineData.resetDistanceMatrices()
            }
        }
    }
    
    
}

#Preview {
    SelectMLModelView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData())
}
