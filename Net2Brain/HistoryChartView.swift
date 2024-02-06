//
//  HistoryChartView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 02.02.24.
//

import SwiftUI
import Charts

struct HistoryChartView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
        
    @State var historyEntry: HistoryEntry
    
    @State var explanation = Explanation(title: "explanation.general.alert.title", description: "explanation.filler", show: false)
    
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
            PipelineSelectionView(pipelineParameters: parametersBinding, currentlySelectedParameter: .none)
            
            Chart {
                ForEach(sortedRoiOutput(), id: \.self) { rsaOutput in
                    BarMark(
                        x: .value("pipeline.evaluation.chart.r2", rsaOutput.r2),
                        y: .value("pipeline.evaluation.chart.roi", rsaOutput.roi)
                    ).foregroundStyle(by: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer)))
                        .position(by: .value("pipeline.evaluation.chart.layer", getLayerName(rsaOutput.layer)))
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
            
            Button("explanation.general.button.title", systemImage: "questionmark.circle", action: {
                explanation.show.toggle()
            }).padding([.top])
            
        }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(dateFormatter.string(from: historyEntry.date))
            .toolbar {
                Button("button.history.entry.delete", systemImage: "trash", role: .destructive) {
                    modelContext.delete(historyEntry)
                    dismiss()
                }
            }
            .sheet(isPresented: $explanation.show) {
                /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
                ExplanationSheet(sheetTitle: $explanation.title, sheetDescription: $explanation.description)
            }
    }
    
    func getLayerName(_ key: String) -> String {
        return historyEntry.pipelineParameters.mlModel.layers.filter({ $0.coremlKey == key }).first?.name ?? ""
    }
    
    func sortedRoiOutput() -> [RSAOutput] {
        let originalLayerKeys = historyEntry.pipelineParameters.mlModel.layers.map { $0.coremlKey }
        
        let sortedAllRoisOutput = historyEntry.roiOutput.sorted(by: {
            (originalLayerKeys.firstIndex(of: $0.layer) ?? 0) < (originalLayerKeys.firstIndex(of: $1.layer) ?? 0)
        })
        return sortedAllRoisOutput
    }
}

#Preview {
    HistoryChartView(historyEntry: HistoryEntry())
}
