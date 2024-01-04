//
//  HeatmapChart.swift
//  Net2Brain
//
//  Created by Marco Weßel on 29.11.23.
//

import SwiftUI
import Charts
import Matft

struct HeatmapChart: View {
    /// heatmap from matplotlib/nilearn ("cold_hot")
    let heatmap = [
        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.28409019, green: 1.0, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0, green: 0.71212101, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0, green: 0.23484906, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0, green: 0.0, blue: 0.75755961, alpha: 1.0),
        UIColor(red: 0.0, green: 0.0, blue: 0.2802532, alpha: 1.0),
        UIColor(red: 0.2802532, green: 0.0, blue: 0.0, alpha: 1.0),
        UIColor(red: 0.75755961, green: 0.0, blue: 0.0, alpha: 1.0),
        UIColor(red: 1.0, green: 0.23484906, blue: 0.0, alpha: 1.0),
        UIColor(red: 1.0, green: 0.71212101, blue: 0.0, alpha: 1.0),
        UIColor(red: 1.0, green: 1.0, blue: 0.28409019, alpha: 1.0),
        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    ].map {
        Color(uiColor: $0)
    }
    
    var matrix: MfArray
    
    var body: some View {
        Chart {
            ForEach(0..<matrix.shape[0], id: \.self) { x in
                ForEach(0..<matrix.shape[1], id: \.self) { y in
                    RectangleMark(
                        xStart: .value("", x),
                        xEnd: .value("", x + 1),
                        yStart: .value("", y),
                        yEnd: .value("", y + 1)
                    ).foregroundStyle(by: .value("", matrix.item(indices: [x, y], type: Float.self)))
                }
            }
        }
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        //.chartXAxisLabel("ROI")
        //.chartXScale(domain: 0...1)
        //.chartYAxisLabel("Hemisphere")
        //.chartForegroundStyleScale(range: Gradient(colors: [.blue, .green]))
        .chartForegroundStyleScale(range: Gradient(colors: heatmap))
        .chartLegend(.hidden)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    let matrix = MfArray((1...100).map { _ in Float.random(in: 0...1) }, shape: [10, 10])
    return HeatmapChart(matrix: matrix)
}
