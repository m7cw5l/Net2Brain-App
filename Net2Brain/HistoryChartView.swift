//
//  HistoryChartView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 02.02.24.
//

import SwiftUI

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
            
            RSAChart(data: historyEntry.roiOutput, pipelineParameters: PipelineParameters(historyPipelineParameters: self.historyEntry.pipelineParameters))
            
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
}

#Preview {
    HistoryChartView(historyEntry: HistoryEntry())
}
