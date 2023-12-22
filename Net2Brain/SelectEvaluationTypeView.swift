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
    
    @State var allRoisOutput: [RSAOutput] = []
    
    @State var isCalculating = false
    @State var rsaStatus = RSAStatus.none
    @State var rsaProgress = 0.0
    
    var body: some View {
        NavigationStack {
            VStack {
                PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .evaluationType)
                
                Form {
                    Picker("Available Evaluation Types", selection: $pipelineParameters.evaluationType) {
                        ForEach(availableEvaluationTypes, id: \.self) { evalType in
                            VStack(alignment: .leading) {
                                Text(evalType.name)
                                Text(evalType.description).font(.caption)
                            }.tag(evalType)
                        }
                    }.pickerStyle(.inline)
                    
                    if pipelineParameters.evaluationType.name != "" {
                        Picker("Available Parameters for selected Evaluation Type", selection: $pipelineParameters.evaluationParameter) {
                            ForEach(pipelineParameters.evaluationType.parameters, id: \.self) { parameter in
                                VStack(alignment: .leading) {
                                    Text(parameter.name)
                                    Text(parameter.description).font(.caption)
                                }.tag(parameter)
                            }
                        }.pickerStyle(.inline)
                    }
                }
                
                ProgressView(value: rsaProgress, total: 1.0).padding(.horizontal)
                
                
                
                if allRoisOutput.count == 0 {
                    Button(action: {
                        Task {
                            isCalculating = true
                            rsaStatus = .loadingData
                            let rsa = RSA()
                            let brainRdms = await rsa.loadBrainRdms(dataset: pipelineParameters.dataset.name, images: pipelineParameters.datasetImages, progressCallback: { progress in
                                rsaProgress = progress
                            })
                            rsaStatus = .calculatingRSA
                            rsaProgress = 0.0
                            allRoisOutput = await rsa.evaluate(brainRdms: brainRdms, modelName: pipelineParameters.mlModel.name, modelRdms: pipelineData.distanceMatrices, progressCallback: { progress in
                                print("RSA Progress: \(progress)")
                                rsaProgress = progress
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
                        Text(rsaStatus == .loadingData ? "loading Brain RDMs..." : rsaStatus == .calculatingRSA ? "calculating RSA..." : "Calculate RSA").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedProminentButtonStyle())
                        .padding([.leading, .trailing, .bottom])
                        .disabled(pipelineParameters.evaluationType.name == "" || pipelineParameters.evaluationParameter.name == "" || isCalculating)
                } else {
                    NavigationLink(destination: {
                        RSAChartView(pipelineParameters: pipelineParameters, allRoisOutput: allRoisOutput)
                    }, label: {
                        Text("Show RSA Chart").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedProminentButtonStyle())
                        .padding([.leading, .trailing, .bottom])
                        .disabled(pipelineParameters.evaluationType.name == "" || pipelineParameters.evaluationParameter.name == "")
                }
                    
                    
                
            }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Select Evaluation Type")
        }.onAppear {
            let firstEvaluationType = availableEvaluationTypes.first ?? N2BEvaluationType(name: "", description: "", parameters: [])
            pipelineParameters.evaluationType = firstEvaluationType
            pipelineParameters.evaluationParameter = firstEvaluationType.parameters.first ?? N2BEvaluationParameter(name: "", description: "")
        }
    }
}

#Preview {
    SelectEvaluationTypeView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData())
}
