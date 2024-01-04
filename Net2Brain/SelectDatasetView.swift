//
//  RSAView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 23.11.23.
//

import SwiftUI

struct SelectDatasetView: View {
        
    @State var pipelineParameters = PipelineParameters()
    @StateObject var pipelineData = PipelineData()
    
    var body: some View {
        NavigationStack {
            VStack {
                
                PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .dataset)
                
                Form {
                    Picker("pipeline.available.datasets.title", selection: $pipelineParameters.dataset) {
                        ForEach(availableDatasets, id: \.name) { dataset in
                            VStack(alignment: .leading) {
                                Text(dataset.name)
                                Text(dataset.description).font(.caption)
                            }.tag(dataset)
                        }
                    }.pickerStyle(.inline)
                }
                NavigationLink(destination: {
                    SelectDatasetImagesView(pipelineParameters: pipelineParameters, pipelineData: pipelineData)
                }, label: {
                    Text("button.next.title").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding()
                    .disabled(pipelineParameters.dataset.name == "")
            }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("view.pipeline.dataset.title")
            .onChange(of: pipelineParameters.dataset, initial: false) {
                pipelineParameters.resetDatasetImages()
                pipelineData.resetPredictionOutputs()
                pipelineData.resetDistanceMatrices()
            }
        }
    }
}

#Preview {
    SelectDatasetView()
}
