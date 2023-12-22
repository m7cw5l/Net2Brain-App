//
//  SelectRDMMetricView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 24.11.23.
//

import SwiftUI
import Matft

struct SelectRDMMetricView: View {
    
    /*let metrics = ["Euclidian", "Manhattan", "Cosine", "Correlation"]
    
    @Binding var selectedDataset: String
    @Binding var selectedMLModel: String
    @Binding var selectedLayer: String
    @State var selectedMetric = ""*/
    
    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @State var isCalculating = false
    
    @State var showHeatmap = false
    
    var body: some View {
        NavigationStack {
            VStack {
                PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .rdmMetric)
                
                Form {
                    Picker("Available distance metrics", selection: $pipelineParameters.rdmMetric) {
                        ForEach(availableRDMMetrics, id: \.self) { metric in
                            VStack(alignment: .leading) {
                                Text(metric.name)
                                Text(metric.description).font(.caption)
                            }.tag(metric)
                        }
                    }.pickerStyle(.inline)
                }
                
                Button(action: {
                    Task {
                        await calculateDistanceMatrices()
                    }
                }, label: {
                    Text(isCalculating ? "calculating..." : "Calculate Distance Matrix").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding()
                    .disabled(pipelineParameters.rdmMetric.name == "" || pipelineData.distanceMatrices.count != 0 || isCalculating)
                    
                Divider()
                
                Button(action: {
                    showHeatmap.toggle()
                }, label: {
                    Text("Show Heatmap of Metric").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedButtonStyle())
                    .padding([.top, .leading, .trailing])
                    .disabled(pipelineParameters.rdmMetric.name == "" || pipelineData.distanceMatrices.count == 0)
                
                NavigationLink(destination: {
                    SelectEvaluationTypeView(pipelineParameters: pipelineParameters, pipelineData: pipelineData)
                }, label: {
                    Text("Next").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding([.leading, .trailing, .bottom])
                    .disabled(pipelineParameters.rdmMetric.name == "" || pipelineData.distanceMatrices.count == 0)
                
            }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Select Distance Metric")
            .onChange(of: pipelineParameters.rdmMetric) {
                pipelineData.resetDistanceMatrices()
            }
            .sheet(isPresented: $showHeatmap) {
                HeatmapChartView(pipelineParameters: $pipelineParameters, matrices: pipelineData.distanceMatrices)
            }
        }
    }
    
    func calcDistanceMatrix(input: MfArray) async -> MfArray {
        switch pipelineParameters.rdmMetric.name {
        case "Euclidean":
            return await euclidean(x: input) ?? MfArray([-1])
        case "Manhattan":
            return await manhattan(x: input) ?? MfArray([-1])
        case "Cosine":
            return await cosine(x: input) ?? MfArray([-1])
        case "Correlation":
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
    SelectRDMMetricView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData())
}
