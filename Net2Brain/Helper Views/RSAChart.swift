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
    //var pipelineParameters: PipelineParameters
    @EnvironmentObject var pipelineParameters: PipelineParameters
    //@EnvironmentObject var pipelineData: PipelineData
    
    var body: some View {
        Chart {
            
            // grouped by roi
            ForEach(Array(sortedRoiOutput()), id: \.self) { rsaOutput in
                BarMark(
                    x: .value("pipeline.evaluation.chart.r2", rsaOutput.r2),
                    y: .value("pipeline.evaluation.chart.roi", rsaOutput.roi)
                )
                .foregroundStyle(by: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer)))
                //.foregroundStyle(by: .value("pipeline.evaluation.chart.roi", rsaOutput.roi))
                //.foregroundStyle(by: .value("pipeline.evaluation.chart.r2", rsaOutput.r2))
                .position(by: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer)))
                    .annotation(position: .trailing, alignment: .leading, content: {
                        Text(String(format: "%.3f", rsaOutput.r2)).font(.system(size: 10, weight: .bold)).foregroundStyle(Color.secondary)
                    })
                    /*.annotation(position: .overlay, alignment: .trailing, content: {
                        Text(String(format: "%.3f", rsaOutput.r2)).font(.system(size: 10, weight: .bold)).foregroundStyle(Color.white)
                    })*/
                    /*.annotation(position: .overlay, alignment: .leading, content: {
                        Text(getLayerName(rsaOutput.layer)).font(.system(size: 10, weight: .bold)).foregroundStyle(Color.white)
                    })*/
            }
            
            // grouped by layer
            /*ForEach(Array(sortedRoiOutput()), id: \.self) { rsaOutput in
                BarMark(
                    x: .value("pipeline.evaluation.chart.r2", rsaOutput.r2),
                    y: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer))
                )
                //.foregroundStyle(by: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer)))
                .foregroundStyle(by: .value("pipeline.evaluation.chart.roi", rsaOutput.roi))
                //.foregroundStyle(by: .value("pipeline.evaluation.chart.r2", rsaOutput.r2))
                .position(by: .value("pipeline.evaluation.chart.roi", rsaOutput.roi))
                    .annotation(position: .overlay, alignment: .trailing, content: {
                        Text(String(format: "%.3f", rsaOutput.r2)).font(.system(size: 10, weight: .bold)).foregroundStyle(Color.white)
                    })
                    /*.annotation(position: .overlay, alignment: .leading, content: {
                        Text(getLayerName(rsaOutput.layer)).font(.system(size: 10, weight: .bold)).foregroundStyle(Color.white)
                    })*/
            }*/
        }
        .chartXAxisLabel(String(localized: "pipeline.evaluation.chart.r2"))
        //.chartXScale(domain: 0...1)
        .chartYAxisLabel(String(localized: "pipeline.evaluation.chart.rois"))
        .chartScrollableAxes(.vertical)
        /*.chartForegroundStyleScale([
         "left": .blue,
         "right": .orange
         ])*/
        //.chartForegroundStyleScale(range: Gradient(colors: Heatmaps().accentColor))
        .padding()
    }
    
    func getLayerName(_ key: String) -> String {
        return pipelineParameters.mlModel.layers.filter({ $0.coremlKey == key }).first?.name ?? ""
    }
    
    func sortedRoiOutput() -> [RSAOutput] {
        let originalLayerKeys = pipelineParameters.mlModel.layers.map { $0.coremlKey }
        
        if !data.isEmpty {
            let sortedAllRoisOutput = data.sorted(by: {
                (originalLayerKeys.firstIndex(of: $0.layer) ?? 0) < (originalLayerKeys.firstIndex(of: $1.layer) ?? 0)
            })
            return sortedAllRoisOutput
        } else {
            return []
        }
        /*return Dictionary(grouping: sortedAllRoisOutput, by: {
            $0.roi
        })*/
    }
}

#Preview {
    RSAChart(data: [])
}
