//
//  HeatmapChartView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 31.10.23.
//

import SwiftUI
import Matft

struct HeatmapChartView: View {
    
    @Environment(\.dismiss) var dismiss
    
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
    
    @EnvironmentObject var pipelineParameters: PipelineParameters
    
    var matrices: [String:MfArray]
    
    @State var currentLayer: N2BMLLayer = N2BMLLayer(name: "", layerDescription: "", coremlKey: "")
    @State var currentMatrix: MfArray = MfArray((1...100).map { _ in Float.random(in: 0...1) }, shape: [10, 10])
    
    let pathImages = Bundle.main.resourcePath!
    
    @State private var chartSelectedX: String? = ""
    @State private var chartSelectedY: String? = ""
    
    var selectedImages: (firstIndex: String, first: String, secondIndex: String, second: String)? {
        guard let chartSelectedX else { return nil }
        guard let chartSelectedY else { return nil }
        if chartSelectedX != "" && chartSelectedY != "" {
            let xIndex = Int(chartSelectedX) ?? 0
            let yIndex = Int(chartSelectedY) ?? 0
            let xImage = pipelineParameters.datasetImages[xIndex]
            let yImage = pipelineParameters.datasetImages[yIndex]
            return (firstIndex: chartSelectedX, first: xImage, secondIndex: chartSelectedY, second: yImage)
        }
        return nil
      }
    
    @State var explanation = Explanation(title: "explanation.general.alert.title", description: "explanation.heatmap.chart", show: false)
    
    var body: some View {
        NavigationStack {
            VStack {
                //PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .none)
                
                VStack {
                    if let selectedImages {
                        VStack(spacing: 2.0) {
                            //Text("pipeline.heatmap.selected.images").font(.headline)
                            HStack {
                                Image(uiImage: UIImage(contentsOfFile: "\(pathImages)/\(selectedImages.first).jpg") ?? UIImage()).resizable().scaledToFit()
                                Image(uiImage: UIImage(contentsOfFile: "\(pathImages)/\(selectedImages.second).jpg") ?? UIImage()).resizable().scaledToFit()
                            }
                            Text(String(format: "Dissimilarity: %.2f", currentMatrix.item(indices: [Int(selectedImages.firstIndex) ?? 0, Int(selectedImages.secondIndex) ?? 0], type: Float.self))).font(.caption)
                        }.padding(.vertical, 12.0)
                            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                            .background()
                            .clipShape(.rect(cornerRadius: 16))
                    } else {
                        VStack {
                            Text("pipeline.heatmap.select.square")
                        }.frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                            .background()
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    
                    
                    if matrices.count > 1 {
                        HStack {
                            Text("pipeline.heatmap.layer.select.title").font(.headline)
                            Picker("pipeline.heatmap.available.layers", selection: $currentLayer) {
                                ForEach(pipelineParameters.mlModelLayers, id: \.self) {
                                    Text($0.name).tag($0)
                                }
                            }//.pickerStyle(.segmented)
                        }
                    }
                }.padding(.horizontal)
                
                //HeatmapChart(matrix: currentMatrix, images: pipelineParameters.datasetImages)
                HeatmapChart(heatmapEntries: getHeatmapData(), images: pipelineParameters.datasetImages, selectedX: $chartSelectedX, selectedY: $chartSelectedY)
                    .aspectRatio(1, contentMode: .fill)
                    .padding(.horizontal)
                
                VStack {
                    LinearGradient(colors: [Color.white, Color.accentColor, Color.black], startPoint: .leading, endPoint: .trailing)
                        .frame(height: 16.0)
                        .clipShape(.rect(cornerRadius: 8))
                    HStack {
                        Text("\(String(format: "%.2f", getMatrixMin()))")
                        Spacer()
                        Text("heatmap.legend.zero")
                        Spacer()
                        Text("\(String(format: "%.2f", getMatrixMax()))")
                    }
                }.padding(.horizontal)
                
                Button("explanation.general.button.title", systemImage: "questionmark.circle", action: {
                    explanation.show.toggle()
                }).padding([.top])
            }.padding(.vertical)
            .background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("view.pipeline.heatmap.title")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("button.done.title") {
                            dismiss()
                        }
                    }
                    /*ToolbarItem(placement: .topBarLeading) {
                        Menu("explanation.menu.title", systemImage: "questionmark.circle", content: {
                            Button("What does the heatmap show me?") {
                                
                            }
                        })
                    }*/
                }
        }.onAppear {
            currentLayer = pipelineParameters.mlModelLayers.first ?? N2BMLLayer(name: "", layerDescription: "", coremlKey: "")
            //currentMatrix = matrices.first ?? MfArray([-1])
        }
        .onChange(of: currentLayer, initial: true, {
            currentMatrix = matrices[currentLayer.coremlKey] ?? MfArray([-1])
            //print(currentMatrix)
        })
        /*.onChange(of: chartSelectedX) {
            print(chartSelectedX)
            print(chartSelectedY)
        }*/
        .sheet(isPresented: $explanation.show) {
            /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
            ExplanationSheet(sheetTitle: $explanation.title, sheetDescription: $explanation.description)
        }
    }
    
    func getHeatmapData() -> [HeatmapEntry] {
        var heatmapEntries = [HeatmapEntry]()
        for x in 0..<currentMatrix.shape[0] {
            for y in 0..<currentMatrix.shape[1] {
                heatmapEntries.append(HeatmapEntry(x: "\(x)", y: "\(y)", value: currentMatrix.item(indices: [x, y], type: Float.self)))
            }
        }
        return heatmapEntries
    }
    
    func getMatrixMin() -> Float {
        return currentMatrix.min().item(index: 0, type: Float.self)
    }
    
    func getMatrixMax() -> Float {
        return currentMatrix.max().item(index: 0, type: Float.self)
    }
}

#Preview {
    //let matrix = Matft.arange(start: -50, to: 50, by: 1, shape: [10, 10], mftype: .Float)
    let matrix = MfArray((1...100).map { _ in Float.random(in: 0...1) }, shape: [10, 10])
    let matrix2 = MfArray((1...400).map { _ in Float.random(in: 0...1) }, shape: [20, 20])
    return HeatmapChartView(matrices: ["Test1": matrix, "Test2":matrix2])
}
