//
//  SelectEvaluationTypeView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 25.11.23.
//

import SwiftUI
import Matft

struct SelectEvaluationTypeView: View {
    
    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @Binding var path: NavigationPath
    
    @State var isCalculating = false
    @State var rsaStatus = RSAStatus.none
    @State var rsaProgress = 0.0
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
    
    var body: some View {
        VStack {
            PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .evaluationType)
            
            Form {
                Picker("pipeline.available.evaluation.types.title", selection: $pipelineParameters.evaluationType) {
                    ForEach(availableEvaluationTypes, id: \.self) { evalType in
                        HStack {
                            ExplanationInfoButton(title: evalType.name, description: evalType.description, currentExplanation: $currentExplanation)
                            Text(evalType.name)
                        }.tag(evalType)
                    }
                }.pickerStyle(.inline)
                
                if pipelineParameters.evaluationType.name != "" {
                    Picker("pipeline.available.evaluation.parameters.title", selection: $pipelineParameters.evaluationParameter) {
                        ForEach(pipelineParameters.evaluationType.parameters, id: \.self) { parameter in
                            HStack {
                                ExplanationInfoButton(title: parameter.name, description: parameter.description, currentExplanation: $currentExplanation)
                                Text(parameter.name)
                            }.tag(parameter)
                        }
                    }.pickerStyle(.inline)
                }
            }
            
            ProgressView(value: rsaProgress, total: 1.0).padding(.horizontal)
            
            if pipelineData.allRoisOutput.count == 0 {
                Button(action: {
                    Task {
                        isCalculating = true
                        rsaStatus = .loadingData
                        let rsa = RSA()
                        let brainRdms = await rsa.loadBrainRdms(dataset: pipelineParameters.dataset.name, images: pipelineParameters.datasetImages, progressCallback: { progress in
                            withAnimation {
                                rsaProgress = progress
                            }
                        })
                        rsaStatus = .calculatingRSA
                        rsaProgress = 0.0
                        pipelineData.allRoisOutput = await rsa.evaluate(brainRdms: brainRdms, modelName: pipelineParameters.mlModel.name, modelRdms: pipelineData.distanceMatrices, progressCallback: { progress in
                            withAnimation {
                                rsaProgress = progress
                            }
                        })
                        
                        isCalculating = false
                        rsaStatus = .none
                        /*let rois = ["visual", "body", "face", "place", "word", "anatomical"]
                        let layers = alexnetLayers.map {
                            $0.name
                        }
                        for roi in rois {
                            for layer in layers {
                                allRoisOutput.append(RSAOutput(roi: roi, layer: layer, model: "AlexNet", r2: Double.random(in: 0...5), significance: Double.random(in: 0...1), sem: Double.random(in: 0...1)))
                            }
                        }*/
                        //print(allRoisOutput)
                    }
                }, label: {
                    Text(rsaStatus == .loadingData ? "pipeline.evaluation.progress.loading" : rsaStatus == .calculatingRSA ? "pipeline.evaluation.progress.calculating" : "pipeline.evaluation.button.start.title").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding([.leading, .trailing, .bottom])
                    .disabled(pipelineParameters.evaluationType.name == "" || pipelineParameters.evaluationParameter.name == "" || isCalculating)
            } else {
                Button(action: {
                    path.append(PipelineView.rsaChart)
                }, label: {
                    Text("pipeline.evaluation.button.chart.title").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding([.leading, .trailing, .bottom])
                    .disabled(pipelineParameters.evaluationType.name == "" || pipelineParameters.evaluationParameter.name == "")
            }
                
                
            
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("view.pipeline.evaluation.title")
        .toolbar {
            RestartPipelineButton(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
            Menu("explanation.menu.title", systemImage: "questionmark.circle", content: {
                ExplanationMenuButton(title: "explanation.evaluation.type.title", description: "explanation.evaluation.type", currentExplanation: $currentExplanation)
            })
        }.sheet(isPresented: $currentExplanation.show) {
            /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
            ExplanationSheet(sheetTitle: $currentExplanation.title, sheetDescription: $currentExplanation.description)
        }
        .onAppear {
            let firstEvaluationType = availableEvaluationTypes.first ?? N2BEvaluationType(name: "", description: "", parameters: [])
            pipelineParameters.evaluationType = firstEvaluationType
            pipelineParameters.evaluationParameter = firstEvaluationType.parameters.first ?? N2BEvaluationParameter(name: "", description: "")
        }
    }
}

#Preview {
    SelectEvaluationTypeView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData(), path: .constant(NavigationPath()))
}
