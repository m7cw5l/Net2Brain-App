//
//  HistoryOverview.swift
//  Net2Brain
//
//  Created by Marco Weßel on 02.02.24.
//

import SwiftUI
import SwiftData

struct HistoryOverview: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var path: NavigationPath
    
    @Query(sort: \HistoryEntry.date, order: .reverse) var historyEntries: [HistoryEntry]
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        List(historyEntries) { historyEntry in
            NavigationLink(destination: {
                HistoryChartView(historyEntry: historyEntry)
                    .environmentObject(PipelineParameters(historyPipelineParameters: historyEntry.pipelineParameters))
            }, label: {
                VStack(alignment: .leading) {
                    Text(dateFormatter.string(from: historyEntry.date))
                    Text("\(historyEntry.pipelineParameters.dataset.name) | \(historyEntry.pipelineParameters.mlModel.name) | \(historyEntry.pipelineParameters.rdmMetric.name) | \(historyEntry.pipelineParameters.evaluationType.name) – \(historyEntry.pipelineParameters.evaluationParameter.name)").font(.caption)
                }
            }).swipeActions {
                Button("button.history.entry.delete", systemImage: "trash", role: .destructive) {
                    modelContext.delete(historyEntry)
                }
            }
        }.overlay(Group {
            if historyEntries.isEmpty {
                Text("history.list.empty").foregroundStyle(Color.secondary).multilineTextAlignment(.center).padding()
            }
        })
        .navigationTitle("view.history.title")
    }
}

#Preview {
    HistoryOverview(path: .constant(NavigationPath()))
}
