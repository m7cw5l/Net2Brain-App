//
//  HistoryChartView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 02.02.24.
//

import SwiftUI
import Matft

struct HistoryChartView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
        
    @State var historyEntry: HistoryEntry
    
    @State var showHeatmap = false
    
    @State var currentExplanation = Explanation(title: "", description: "", show: false)
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-custom-bindings ; 02.02.2024 09:18
        let parametersBinding = Binding(
            get: { PipelineParameters(historyPipelineParameters: self.historyEntry.pipelineParameters) },
            set: { self.historyEntry.pipelineParameters = HistoryPipelineParameters(pipelineParameters: $0) }
        )
        
        VStack {
            PipelineSelectionView(pipelineParameters: parametersBinding, currentlySelectedParameter: .none, allowCollapse: true)
            
            RSAChart(data: historyEntry.roiOutput, pipelineParameters: PipelineParameters(historyPipelineParameters: self.historyEntry.pipelineParameters))
            
            /*Button("explanation.general.button.title", systemImage: "questionmark.circle", action: {
                explanation.show.toggle()
            })//.padding([.top])*/
            
            Button(action: {
                showHeatmap.toggle()
            }, label: {
                Label("pipeline.rdm.button.heatmap.title", systemImage: "square.grid.3x3.square")
                .frame(maxWidth: .infinity).padding(6)
            }).buttonStyle(BorderedButtonStyle())
                .padding()
            
        }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(dateFormatter.string(from: historyEntry.date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("button.history.entry.delete", systemImage: "trash", role: .destructive) {
                    modelContext.delete(historyEntry)
                    dismiss()
                }
                Menu("explanation.menu.title", systemImage: "questionmark.circle", content: {
                    ExplanationMenuButton(buttonTitle: "explanation.general.button.title", title: "explanation.general.alert.title", description: "explanation.filler", currentExplanation: $currentExplanation)
                })
            }.sheet(isPresented: $showHeatmap) {
                HeatmapChartView(pipelineParameters: parametersBinding, matrices: historyEntry.distanceMatrices.reduce(into: [String:MfArray]()) {
                    $0[$1.layerName] = MfArray($1.data, mftype: .Float, shape: $1.shape)
                })
            }
            .sheet(isPresented: $currentExplanation.show) {
                /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
                ExplanationSheet(sheetTitle: $currentExplanation.title, sheetDescription: $currentExplanation.description)
            }
    }
}

#Preview {
    HistoryChartView(historyEntry: HistoryEntry())
}
