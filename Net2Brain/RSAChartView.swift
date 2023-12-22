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
    
    var body: some View {
        VStack {
            PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .none)
            
            Chart {
                ForEach(allRoisOutput, id: \.self) { rsaOutput in
                    BarMark(
                        x: .value("R2", rsaOutput.r2),
                        y: .value("ROI", rsaOutput.roi)
                    ).foregroundStyle(by: .value("Layer", rsaOutput.layer))
                        .position(by: .value("Layer", rsaOutput.layer))
                }
            }
            .chartXAxisLabel("R2")
            //.chartXScale(domain: 0...1)
            .chartYAxisLabel("ROIs")
            /*.chartForegroundStyleScale([
             "left": .blue,
             "right": .orange
             ])*/
            .padding()
            
        }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("RSA Chart")
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
