//
//  PipelineSelectionRow.swift
//  Net2Brain
//
//  Created by Marco Weßel on 28.11.23.
//

import SwiftUI

struct PipelineSelectionRow: View {
    
    var title: String
    var description: String
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(title)).font(.headline)
            Spacer()
            Text(LocalizedStringKey(description))
        }
    }
}

#Preview {
    PipelineSelectionRow(title: "", description: "")
}
