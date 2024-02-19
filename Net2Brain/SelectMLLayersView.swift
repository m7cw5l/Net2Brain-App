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
    
    //@Environment(\.modelContext) var modelContext
        
    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @Binding var path: NavigationPath
    
    @State var isCalculating = false
    @State var predictionStatus = PredictionStatus.none
    @State var predictionProgress = 0.0
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
    
    var body: some View {
        VStack {
            
            PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .mlModelLayer)
            
            HStack {
                Button(action: {
                    pipelineParameters.mlModelLayers.removeAll()
                    pipelineParameters.mlModelLayers.append(contentsOf: pipelineParameters.mlModel.layers)
                }, label: {
                    Text("button.select.all.title").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedButtonStyle())
                    .padding(.leading)
                    .disabled(pipelineParameters.mlModelLayers.count == pipelineParameters.mlModel.layers.count)
                
                Button(action: {
                    pipelineParameters.mlModelLayers.removeAll()
                }, label: {
                    Text("button.deselect.all.title").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedButtonStyle())
                    .padding(.trailing)
                    .disabled(pipelineParameters.mlModelLayers.count == 0)
            }
            List {
                Section("pipeline.available.model.layers.title") {
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
                                    Text(layer.layerDescription).font(.caption).fontDesign(.monospaced).foregroundColor(.primary)
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
                    Text(predictionStatus == .predicting ? "pipeline.ml.progress.predicting" : predictionStatus == .processingData ? "pipeline.ml.progress.processing" : "pipeline.ml.button.start.title").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding([.leading, .trailing, .bottom])
                    .disabled(pipelineParameters.mlModelLayers.count == 0 || pipelineData.mlPredictionOutputs.count != 0 || isCalculating)
            } else {
                Button(action: {
                    path.append(PipelineView.rdmMetric)
                }, label: {
                    Text("button.next.title").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding([.leading, .trailing, .bottom])
                    .disabled(pipelineParameters.mlModelLayers.count == 0 || pipelineData.mlPredictionOutputs.count == 0)
            }
            
        }.background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("view.pipeline.model.layer.title")
        .toolbar {
            RestartPipelineButton(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
            Menu("explanation.menu.title", systemImage: "questionmark.circle", content: {
                ExplanationMenuButton(title: "explanation.model.layer.title", description: "explanation.model.layer", currentExplanation: $currentExplanation)
            })
        }
        .onChange(of: pipelineParameters.mlModelLayers) {
            pipelineData.resetAll()
        }.sheet(isPresented: $currentExplanation.show) {
            /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
            ExplanationSheet(sheetTitle: $currentExplanation.title, sheetDescription: $currentExplanation.description)
        }
    }
    
    func predict() async {
        isCalculating = true
        predictionStatus = .predicting
        let layers = pipelineParameters.mlModelLayers.map { $0.coremlKey }
        let mlPredict = MLPredict()
        
        switch pipelineParameters.mlModel.name {
        case "AlexNet":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictAlexNet(imageNames: pipelineParameters.datasetImages, selectedModel: pipelineParameters.mlModel, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                withAnimation {
                    self.predictionProgress = progress
                }
            })
        case "ResNet18":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictResNet18(imageNames: pipelineParameters.datasetImages, selectedModel: pipelineParameters.mlModel, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                withAnimation {
                    self.predictionProgress = progress
                }
            })
        case "ResNet34":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictResNet34(imageNames: pipelineParameters.datasetImages, selectedModel: pipelineParameters.mlModel, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                withAnimation {
                    self.predictionProgress = progress
                }
            })
        case "ResNet50":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictResNet50(imageNames: pipelineParameters.datasetImages, selectedModel: pipelineParameters.mlModel, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                withAnimation {
                    self.predictionProgress = progress
                }
            })
        case "VGG11":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictVgg11(imageNames: pipelineParameters.datasetImages, selectedModel: pipelineParameters.mlModel, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                withAnimation {
                    self.predictionProgress = progress
                }
            })
        case "VGG13":
            self.pipelineData.mlPredictionOutputs = await mlPredict.predictVgg13(imageNames: pipelineParameters.datasetImages, selectedModel: pipelineParameters.mlModel, layers: layers, progressCallback: { status, progress in
                self.predictionStatus = status
                withAnimation {
                    self.predictionProgress = progress
                }
            })
        default:
            break
        }
        isCalculating = false
        predictionStatus = .none
    }
}

#Preview {
    SelectMLLayersView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData(), path: .constant(NavigationPath()))
}
