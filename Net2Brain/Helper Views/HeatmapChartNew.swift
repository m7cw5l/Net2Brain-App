//
//  HeatmapChartNew.swift
//  Net2Brain
//
//  Created by Marco Weßel on 11.01.24.
//

import SwiftUI
import Charts
import Matft

struct HeatmapEntry: Hashable {
    var x: String
    var y: String
    var value: Float
}

struct HeatmapChartNew: View {
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
    
    //var matrix: MfArray
    var heatmapEntries: [HeatmapEntry]
    
    var images: [String]
    
    let pathImages = Bundle.main.resourcePath!
    
    @Binding var selectedX: String?
    @Binding var selectedY: String?
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: UIImage(contentsOfFile: "\(pathImages)/\(image).jpg") ?? UIImage()).resizable().scaledToFit()
                    }
                }.frame(width: geo.size.width / CGFloat(images.count + 1), height: geo.size.width - geo.size.width / CGFloat(images.count + 1), alignment: .trailing)
                    .background(.red)
                    .padding(.top, geo.size.width / CGFloat(images.count + 1))
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: UIImage(contentsOfFile: "\(pathImages)/\(image).jpg") ?? UIImage()).resizable().scaledToFit()
                        }
                    }.frame(width: geo.size.width - geo.size.width / CGFloat(images.count + 1), height: geo.size.width / CGFloat(images.count + 1), alignment: .trailing)
                        .background(.red)
                    Chart {
                        /// https://developer.apple.com/wwdc23/10037 ; 11.01.2024 08:44
                        ForEach(heatmapEntries, id: \.self) { entry in
                            RectangleMark(
                                x: .value("x", entry.x),
                                y: .value("y", entry.y),
                                width: MarkDimension(floatLiteral: geo.size.width / CGFloat(images.count + 1)),
                                height: MarkDimension(floatLiteral: geo.size.width / CGFloat(images.count + 1))
                            )
                            .foregroundStyle(by: .value("Value", entry.value))
                        }
                        if let selectedX, let selectedY {
                            if selectedX != "" && selectedY != "" {
                                RectangleMark(
                                    x: .value("x", selectedX),
                                    y: .value("y", selectedY),
                                    width: MarkDimension(floatLiteral: geo.size.width / CGFloat(images.count + 1)),
                                    height: MarkDimension(floatLiteral: geo.size.width / CGFloat(images.count + 1))
                                ).foregroundStyle(Color.gray.opacity(0.5))
                            }
                        }
                    }.frame(width: geo.size.width - geo.size.width / CGFloat(images.count + 1), height: geo.size.width - geo.size.width / CGFloat(images.count + 1))
                    /// https://developer.apple.com/documentation/charts/customizing-axes-in-swift-charts#Set-the-domain-of-an-axis ; 10.01.2024 13:45
                        .chartYAxis(.hidden)
                        .chartXAxis(.hidden)
                    //.chartForegroundStyleScale(range: Gradient(colors: heatmap))
                        .chartForegroundStyleScale(range: Gradient(colors: [Color.white, Color.accentColor, Color.black]))
                        .chartLegend(.hidden)
                        .chartXSelection(value: $selectedX)
                        .chartYSelection(value: $selectedY)
                }
            }
        }.aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    let matrix = MfArray((1...100).map { _ in Float.random(in: 0...1) }, shape: [10, 10])
    let images = (1...10).map { String(format: "78images_%05d.jpg", $0) }
    
    var heatmapEntries = [HeatmapEntry]()
    for x in 0..<matrix.shape[0] {
        for y in 0..<matrix.shape[1] {
            heatmapEntries.append(HeatmapEntry(x: "\(x)", y: "\(y)", value: matrix.item(indices: [x, y], type: Float.self)))
        }
    }
    
    return HeatmapChartNew(heatmapEntries: heatmapEntries, images: images, selectedX: .constant(""), selectedY: .constant(""))
}
