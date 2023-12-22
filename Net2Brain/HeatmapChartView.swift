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
    
    var body: some View {
        NavigationStack {
            VStack {
                PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .none)
                
                if matrices.count > 1 {
                    Picker("Available distance metrics", selection: $currentLayer) {
                        ForEach(pipelineParameters.mlModelLayers, id: \.self) {
                            Text($0.name).tag($0)
                        }
                    }//.pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                HeatmapChart(matrix: currentMatrix)
                    //.padding()
                    //.background(Color(uiColor: .secondarySystemGroupedBackground))
                    //.clipShape(.rect(cornerRadius: 16))
                    //.padding(.horizontal)
                
            }.padding(.vertical)
            .background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("Heatmap of Metric")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    Button("Done") {
                        dismiss()
                    }
                }
        }.onAppear {
            currentLayer = pipelineParameters.mlModelLayers.first ?? N2BMLLayer(name: "", description: "", coremlKey: "")
            //currentMatrix = matrices.first ?? MfArray([-1])
        }
        .onChange(of: currentLayer, initial: true, {
            currentMatrix = matrices[currentLayer.coremlKey] ?? MfArray([-1])
        })
    }
}

#Preview {
    //let matrix = Matft.arange(start: -50, to: 50, by: 1, shape: [10, 10], mftype: .Float)
    let matrix = MfArray((1...100).map { _ in Float.random(in: 0...1) }, shape: [10, 10])
    let matrix2 = MfArray((1...400).map { _ in Float.random(in: 0...1) }, shape: [20, 20])
    return HeatmapChartView(pipelineParameters: .constant(PipelineParameters()), matrices: ["Test1": matrix, "Test2":matrix2])
}
