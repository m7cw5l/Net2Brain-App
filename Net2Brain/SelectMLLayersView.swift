//
//  SelectMLLayersView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 30.11.23.
//

import SwiftUI
import SwiftData
import Matft

struct SelectMLLayersView: View {
    
    @Environment(\.modelContext) var modelContext
        
    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @State var isCalculating = false
    @State var predictionStatus = PredictionStatus.none
    @State var predictionProgress = 0.0
    
    var body: some View {
        NavigationStack {
            VStack {
                
                PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .mlModelLayer)
                
                HStack {
                    Button(action: {
                        pipelineParameters.mlModelLayers.removeAll()
                        pipelineParameters.mlModelLayers.append(contentsOf: pipelineParameters.mlModel.layers)
                    }, label: {
                        Text("Select All").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                        .padding(.leading)
                        .disabled(pipelineParameters.mlModelLayers.count == pipelineParameters.mlModel.layers.count)
                    
                    Button(action: {
                        pipelineParameters.mlModelLayers.removeAll()
                    }, label: {
                        Text("Deselect All").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                        .padding(.trailing)
                        .disabled(pipelineParameters.mlModelLayers.count == 0)
                }
                List {
                    Section("Available Layers for selected ML Model") {
                        ForEach(pipelineParameters.mlModel.layers, id: \.name) { layer in
                            Button(action: {
                                if pipelineParameters.mlModelLayers.contains(layer) {
                                    pipelineParameters.mlModelLayers.removeAll { $0 == layer }
                                } else {
                                    pipelineParameters.mlModelLayers.append(layer)
                                }
                            }, label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(layer.name).foregroundColor(.primary)
                                        Text(layer.description).font(.caption).foregroundColor(.primary)
                                    }
                                    if pipelineParameters.mlModelLayers.contains(layer) {
                                        Spacer()
                                        Image(systemName: "checkmark").fontWeight(.semibold)//.foregroundStyle(.accent)
                                    }
                                }
                            })
                        }
                    }
                }
                
                ProgressView(value: predictionProgress, total: 1.0).padding(.horizontal)
                
                if pipelineData.mlPredictionOutputs.count == 0 {
                    Button(action: {
                        Task {
                            await predict()
                        }
                    }, label: {
                        Text(predictionStatus == .predicting ? "predicting..." : predictionStatus == .processingData ? "processing data..." : "Run Prediction").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedProminentButtonStyle())
                        .padding()
                        .disabled(pipelineParameters.mlModelLayers.count == 0 || pipelineData.mlPredictionOutputs.count != 0 || isCalculating)
                } else {
                    NavigationLink(destination: {
                        SelectRDMMetricView(pipelineParameters: pipelineParameters, pipelineData: pipelineData)
                    }, label: {
                        Text("Next").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedProminentButtonStyle())
                        .padding()
                        .disabled(pipelineParameters.mlModelLayers.count == 0 || pipelineData.mlPredictionOutputs.count == 0)
                }
                
            }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Select ML Model Layers")
            .onChange(of: pipelineParameters.mlModelLayers) {
                pipelineData.resetPredictionOutputs()
                pipelineData.resetDistanceMatrices()
            }
        }
    }
    
    func predict() async {
        isCalculating = true
        predictionStatus = .predicting
        let layers = pipelineParameters.mlModelLayers.map { $0.coremlKey }
        let mlPredict = MLPredict()
        
        switch pipelineParameters.mlModel.name {
        case "AlexNet":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictAlexNet(imageNames: pipelineParameters.datasetImages, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                self.predictionProgress = progress
            })
        case "ResNet18":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictResNet18(imageNames: pipelineParameters.datasetImages, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                self.predictionProgress = progress
            })
        case "ResNet34":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictResNet34(imageNames: pipelineParameters.datasetImages, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                self.predictionProgress = progress
            })
        case "ResNet50":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictResNet50(imageNames: pipelineParameters.datasetImages, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                self.predictionProgress = progress
            })
        case "VGG11":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictVgg11(imageNames: pipelineParameters.datasetImages, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                self.predictionProgress = progress
            })
        case "VGG13":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictVgg13(imageNames: pipelineParameters.datasetImages, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                self.predictionProgress = progress
            })
        default:
            break
        }
        isCalculating = false
        predictionStatus = .none
    }
}

#Preview {
    SelectMLLayersView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData())
}
