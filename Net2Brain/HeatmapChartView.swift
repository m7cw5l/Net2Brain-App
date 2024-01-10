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
    
    @Binding var pipelineParameters: PipelineParameters
    
    var matrices: [String:MfArray]
    
    @State var currentLayer: N2BMLLayer = N2BMLLayer(name: "", description: "", coremlKey: "")
    @State var currentMatrix: MfArray = MfArray((1...100).map { _ in Float.random(in: 0...1) }, shape: [10, 10])
    
    @State var explanation = Explanation(title: "explanation.general.alert.title", description: "explanation.filler", show: false)
    
    var body: some View {
        NavigationStack {
            VStack {
                //PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .none)
                
                if matrices.count > 1 {
                    HStack {
                        Text("pipeline.heatmap.layer.select.title").font(.headline)
                        Picker("pipeline.heatmap.available.layers", selection: $currentLayer) {
                            ForEach(pipelineParameters.mlModelLayers, id: \.self) {
                                Text($0.name).tag($0)
                            }
                        }//.pickerStyle(.segmented)
                    }.padding(.horizontal)
                }
                HeatmapChart(matrix: currentMatrix, images: pipelineParameters.datasetImages).padding(.horizontal)
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
            currentLayer = pipelineParameters.mlModelLayers.first ?? N2BMLLayer(name: "", description: "", coremlKey: "")
            //currentMatrix = matrices.first ?? MfArray([-1])
        }
        .onChange(of: currentLayer, initial: true, {
            currentMatrix = matrices[currentLayer.coremlKey] ?? MfArray([-1])
            //print(currentMatrix)
        })
        .sheet(isPresented: $explanation.show) {
            /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
            ExplanationSheet(sheetTitle: $explanation.title, sheetDescription: $explanation.description)
        }
    }
}

#Preview {
    //let matrix = Matft.arange(start: -50, to: 50, by: 1, shape: [10, 10], mftype: .Float)
    let matrix = MfArray((1...100).map { _ in Float.random(in: 0...1) }, shape: [10, 10])
    let matrix2 = MfArray((1...400).map { _ in Float.random(in: 0...1) }, shape: [20, 20])
    return HeatmapChartView(pipelineParameters: .constant(PipelineParameters()), matrices: ["Test1": matrix, "Test2":matrix2])
}
