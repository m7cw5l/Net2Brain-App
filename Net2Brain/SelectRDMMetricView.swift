//
//  SelectRDMMetricView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 24.11.23.
//

import SwiftUI
import Matft

struct SelectRDMMetricView: View {
    
    @EnvironmentObject var pipelineParameters: PipelineParameters
    @EnvironmentObject var pipelineData: PipelineData
    
    @Binding var path: NavigationPath
    
    @State var isCalculating = false
    
    @State var showHeatmap = false
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
    
    var body: some View {
        VStack {
            PipelineSelectionView(currentlySelectedParameter: .rdmMetric)
            
            Form {
                Picker("pipeline.available.metrics.title", selection: $pipelineParameters.rdmMetric) {
                    ForEach(availableRDMMetrics, id: \.self) { metric in
                        HStack {
                            ExplanationInfoButton(title: metric.name, description: metric.metricDescription, currentExplanation: $currentExplanation)
                            Text(metric.name)
                        }.tag(metric)
                    }
                }.pickerStyle(.inline)
            }
            
            Button(action: {
                Task {
                    await calculateDistanceMatrices()
                }
            }, label: {
                Text(isCalculating ? "pipeline.rdm.calculating" : "pipeline.rdm.button.start.title").frame(maxWidth: .infinity).padding(6)
            }).buttonStyle(BorderedProminentButtonStyle())
                .padding()
                .disabled(pipelineParameters.rdmMetric.name == "" || pipelineData.distanceMatrices.count != 0 || isCalculating)
                
            Divider()
            
            Button(action: {
                showHeatmap.toggle()
            }, label: {
                Label("pipeline.rdm.button.heatmap.title", systemImage: "square.grid.3x3.square")
                .frame(maxWidth: .infinity).padding(6)
            }).buttonStyle(BorderedButtonStyle())
                .padding([.top, .leading, .trailing])
                .disabled(pipelineParameters.rdmMetric.name == "" || pipelineData.distanceMatrices.count == 0 || isCalculating)
            
            Button(action: {
                path.append(PipelineView.evaluationType)
            }, label: {
                Text("button.next.title").frame(maxWidth: .infinity).padding(6)
            }).buttonStyle(BorderedProminentButtonStyle())
                .padding([.leading, .trailing, .bottom])
                .disabled(pipelineParameters.rdmMetric.name == "" || pipelineData.distanceMatrices.count == 0 || isCalculating)
            
        }.background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("view.pipeline.rdm.title")
        .toolbar {
            RestartPipelineButton(path: $path)
            Menu("explanation.menu.title", systemImage: "questionmark.circle", content: {
                ExplanationMenuButton(title: "explanation.rdm.title", description: "explanation.rdm", currentExplanation: $currentExplanation)
            })
        }
        .onChange(of: pipelineParameters.rdmMetric) {
            pipelineData.resetDistanceMatrices()
            pipelineData.resetRoiOutputs()
        }
        .sheet(isPresented: $showHeatmap) {
            HeatmapChartView(matrices: pipelineData.distanceMatrices)
        }.sheet(isPresented: $currentExplanation.show) {
            /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
            ExplanationSheet(sheetTitle: $currentExplanation.title, sheetDescription: $currentExplanation.description)
        }
    }
    
    func calcDistanceMatrix(input: MfArray) async -> MfArray {
        switch pipelineParameters.rdmMetric.name {
        case String(localized: "pipeline.rdm.metric.euclidean.title"):
            return await euclidean(x: input) ?? MfArray([-1])
        case String(localized: "pipeline.rdm.metric.manhattan.title"):
            return await manhattan(x: input) ?? MfArray([-1])
        case String(localized: "pipeline.rdm.metric.cosine.title"):
            return await cosine(x: input) ?? MfArray([-1])
        case String(localized: "pipeline.rdm.metric.correlation.title"):
            return await correlation(x: input) ?? MfArray([-1])
        default:
            break
        }
        return MfArray([-1])
    }

    func calculateDistanceMatrices() async {
        isCalculating = true
        
        for (layer, output) in pipelineData.mlPredictionOutputs {
            pipelineData.distanceMatrices[layer] = await calcDistanceMatrix(input: output).swapaxes(axis1: 0, axis2: 1)
            //pipelineData.mlPredictionOutputs.removeValue(forKey: layer)
        }
        
        /*for mlPredictionOutput in pipelineData.mlPredictionOutputs {
            switch pipelineParameters.rdmMetric.name {
            case "Euclidian":
                self.pipelineData.distanceMatrices.append(await euclidian(x: mlPredictionOutput) ?? MfArray([-1]))
                break
            case "Manhattan":
                self.pipelineData.distanceMatrices.append(await manhattan(x: mlPredictionOutput) ?? MfArray([-1]))
                break
            case "Cosine":
                self.pipelineData.distanceMatrices.append(await cosine(x: mlPredictionOutput) ?? MfArray([-1]))
                break
            case "Correlation":
                self.pipelineData.distanceMatrices.append(await correlation(x: mlPredictionOutput) ?? MfArray([-1]))
                break
            default:
                break
            }
        }*/
        for (_, distanceMatrix) in pipelineData.distanceMatrices {
            print(distanceMatrix.shape)
        }
        isCalculating = false
    }
}

#Preview {
    SelectRDMMetricView(path: .constant(NavigationPath()))
}
