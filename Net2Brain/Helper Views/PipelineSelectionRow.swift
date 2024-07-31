//
//  PipelineSelectionRow.swift
//  Net2Brain
//
//  Created by Marco Weßel on 28.11.23.
//

import SwiftUI

/// row displaying a parameter title and a corresponding value
/// used in the `PipelineSelectionView`
/// - Parameters:
///   - title: title displayed on the left side
///   - description: description displayed on the right side
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
