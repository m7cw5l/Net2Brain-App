//
//  RSAView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 23.11.23.
//

import SwiftUI

struct SelectDatasetView: View {
    
    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @Binding var path: NavigationPath
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
    
    var body: some View {
        VStack {
            
            PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .dataset)
            
            Form {
                Picker("pipeline.available.datasets.title", selection: $pipelineParameters.dataset) {
                    ForEach(availableDatasets, id: \.name) { dataset in
                        HStack {
                            ExplanationInfoButton(title: dataset.name, description: dataset.datasetDescription, currentExplanation: $currentExplanation)
                            Text(dataset.name)
                        }.tag(dataset)
                    }
                }.pickerStyle(.inline)
            }
            
            Button(action: {
                path.append(PipelineView.datasetImages)
            }, label: {
                Text("button.next.title").frame(maxWidth: .infinity).padding(6)
            }).buttonStyle(BorderedProminentButtonStyle())
                .padding()
                .disabled(pipelineParameters.dataset.name == "")
            
        }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("view.pipeline.dataset.title")
            .onChange(of: pipelineParameters.dataset, initial: false) {
                pipelineParameters.resetDatasetImages()
                pipelineData.resetAll()
            }.sheet(isPresented: $currentExplanation.show) {
                /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
                ExplanationSheet(sheetTitle: $currentExplanation.title, sheetDescription: $currentExplanation.description)
            }
    }
}

#Preview {
    SelectDatasetView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData(), path: .constant(NavigationPath()))
}
