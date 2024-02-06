//
//  RSAChart.swift
//  Net2Brain
//
//  Created by Marco Weßel on 06.02.24.
//

import SwiftUI
import Charts

struct RSAChart: View {
    
    var data: [RSAOutput]
    var pipelineParameters: PipelineParameters
    
    var body: some View {
        Chart {
            ForEach(sortedRoiOutput(), id: \.self) { rsaOutput in
                BarMark(
                    x: .value("pipeline.evaluation.chart.r2", rsaOutput.r2),
                    y: .value("pipeline.evaluation.chart.roi", rsaOutput.roi)
                ).foregroundStyle(by: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer)))
                    .position(by: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer)))
                    .annotation(position: .trailing, content: {
                        Text(String(format: "%.3f", rsaOutput.r2)).font(.caption).foregroundStyle(Color.secondary)
                    })
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
    }
    
    func getLayerName(_ key: String) -> String {
        return pipelineParameters.mlModel.layers.filter({ $0.coremlKey == key }).first?.name ?? ""
    }
    
    func sortedRoiOutput() -> [RSAOutput] {
        let originalLayerKeys = pipelineParameters.mlModel.layers.map { $0.coremlKey }
        
        let sortedAllRoisOutput = data.sorted(by: {
            (originalLayerKeys.firstIndex(of: $0.layer) ?? 0) < (originalLayerKeys.firstIndex(of: $1.layer) ?? 0)
        })
        return sortedAllRoisOutput
    }
}

#Preview {
    RSAChart(data: [], pipelineParameters: PipelineParameters())
}
