//
//  GlossaryView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 21.03.24.
//

import SwiftUI

struct GlossaryEntry {
    let abbreviation: String
    let meaning: String
}

struct GlossaryView: View {
    @Binding var path: NavigationPath
    
    let glossaryEntries = [
        GlossaryEntry(abbreviation: "RDM", meaning: "Representational Dissimilarity Matrix"),
        GlossaryEntry(abbreviation: "fMRI", meaning: "Functional magnetic resonance imaging"),
        GlossaryEntry(abbreviation: "MEG", meaning: "Magnetoencephalography"),
        GlossaryEntry(abbreviation: "ROI", meaning: "Region of Interest"),
        GlossaryEntry(abbreviation: "ML", meaning: "Machine Learning"),
        GlossaryEntry(abbreviation: "RSA", meaning: "Representational Similarity Analysis")
    ]
    
    var body: some View {
        let glossaryDict = Dictionary(grouping: glossaryEntries, by: { $0.abbreviation.first?.description.lowercased() ?? "" })
        
        return List {
            ForEach(Array(glossaryDict.keys).sorted(), id: \.self) { key in
                Section(key) {
                    ForEach(glossaryDict[key] ?? [], id: \.abbreviation) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.abbreviation).font(.headline)
                            Text(entry.meaning).font(.body)
                        }
                    }
                }
            }
        }
            .navigationTitle("view.glossary.title")
    }
}

#Preview {
    GlossaryView(path: .constant(NavigationPath()))
}
