//
//  HeatmapChart.swift
//  Net2Brain
//
//  Created by Marco Weßel on 29.11.23.
//

import SwiftUI
import Charts
import Matft

struct HeatmapChartOld: View {
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
    
    var images: [String]
    
    let pathImages = Bundle.main.resourcePath!
    
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
                        ForEach(0..<matrix.shape[0], id: \.self) { x in
                            ForEach(0..<matrix.shape[1], id: \.self) { y in
                                RectangleMark(
                                    xStart: .value("xStart", x),
                                    xEnd: .value("xEnd", x + 1),
                                    yStart: .value("yStart", y),
                                    yEnd: .value("yEnd", y + 1)
                                ).foregroundStyle(by: .value("", matrix.item(indices: [x, y], type: Float.self)))
                                    /*.annotation(position: .overlay, alignment: .center) {
                                        // your Text or other overlay here
                                        Text("\(x), \(y)").font(.caption2)
                                      }*/
                            }
                        }
                    }.frame(width: geo.size.width - geo.size.width / CGFloat(images.count + 1), height: geo.size.width - geo.size.width / CGFloat(images.count + 1))
                    /// https://developer.apple.com/documentation/charts/customizing-axes-in-swift-charts#Set-the-domain-of-an-axis ; 10.01.2024 13:45
                        .chartYScale(domain: [images.count, 0])
                    .chartYAxis(.hidden)
                    .chartXAxis(.hidden)
                    //.chartForegroundStyleScale(range: Gradient(colors: heatmap))
                    .chartForegroundStyleScale(range: Gradient(colors: [Color.white, Color.accentColor]))
                    .chartLegend(.hidden)
                }
            }
            //.chartSymbolScale(range: [0, 1])
            /*.chartXAxisLabel(position: .top, alignment: .trailing, spacing: 0, content: {
                HStack(spacing: 0) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: UIImage(contentsOfFile: "\(pathImages)/\(image).jpg") ?? UIImage()).resizable().scaledToFit()
                    }
                }.frame(width: geo.size.width - geo.size.width / CGFloat(images.count + 1), height: geo.size.width / CGFloat(images.count + 1), alignment: .trailing)
                    .background(.red)
            })*/
        }
    }
}

#Preview {
    let matrix = MfArray((1...100).map { _ in Float.random(in: 0...1) }, shape: [10, 10])
    let images = (1...10).map { String(format: "78images_%05d.jpg", $0) }
    
    return HeatmapChartOld(matrix: matrix, images: images)
}
