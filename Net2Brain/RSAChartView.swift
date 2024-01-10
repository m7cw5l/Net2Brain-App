//
//  RSAChartView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 04.12.23.
//

import SwiftUI
import Charts

struct RSAChartView: View {
    @State var pipelineParameters: PipelineParameters
    
    var allRoisOutput: [RSAOutput]
    
    @State var explanation = Explanation(title: "explanation.general.alert.title", description: "explanation.filler", show: false)
    
    var body: some View {
        VStack {
            PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .none)
            
            Chart {
                ForEach(sortedRoiOutput(), id: \.self) { rsaOutput in
                    BarMark(
                        x: .value("pipeline.evaluation.chart.r2", rsaOutput.r2),
                        y: .value("pipeline.evaluation.chart.roi", rsaOutput.roi)
                    ).foregroundStyle(by: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer)))
                        .position(by: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer)))
                }
            }
            .chartXAxisLabel(String(localized: "pipeline.evaluation.chart.r2"))
            //.chartXScale(domain: 0...1)
            .chartYAxisLabel(String(localized: "pipeline.evaluation.chart.rois"))
            .chartScrollableAxes(.vertical)
            /*.chartForegroundStyleScale([
             "left": .blue,
             "right": .orange
             ])*/
            .padding()
            
            Button("explanation.general.button.title", systemImage: "questionmark.circle", action: {
                explanation.show.toggle()
            }).padding([.top])
            
        }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("view.pipeline.evaluation.chart.title")
            .sheet(isPresented: $explanation.show) {
                /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
                ExplanationSheet(sheetTitle: $explanation.title, sheetDescription: $explanation.description)
            }
    }
    
    func getLayerName(_ key: String) -> String {
        return pipelineParameters.mlModel.layers.filter({ $0.coremlKey == key }).first?.name ?? ""
    }
    
    func sortedRoiOutput() -> [RSAOutput] {
        let originalLayerKeys = pipelineParameters.mlModel.layers.map { $0.coremlKey }
        
        let sortedAllRoisOutput = allRoisOutput.sorted(by: {
            (originalLayerKeys.firstIndex(of: $0.layer) ?? 0) < (originalLayerKeys.firstIndex(of: $1.layer) ?? 0)
        })
        return sortedAllRoisOutput
    }
}

#Preview {
    let rois = ["visual", "body", "face", "place", "word", "anatomical"]
    let layers = alexnetLayers.map {
        $0.name
    }
    var exampleData = [RSAOutput]()
    for roi in rois {
        for layer in layers {
            exampleData.append(RSAOutput(roi: roi, layer: layer, model: "AlexNet", r2: Float.random(in: 0...5), significance: Float.random(in: 0...1), sem: Float.random(in: 0...1)))
        }
    }
    return RSAChartView(pipelineParameters: PipelineParameters(), allRoisOutput: exampleData)
}
