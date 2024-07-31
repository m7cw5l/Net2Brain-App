//
//  ExplanationInfoButton.swift
//  Net2Brain
//
//  Created by Marco Weßel on 09.01.24.
//

import SwiftUI

/// view for a small info button that can be added to list row and shows a explanation when tapped
/// - Parameters:
///   - title: the explanation's title
///   - description: the text of the explanation
struct ExplanationInfoButton: View {
    
    @State var title: String
    @State var description: String
    
    @Binding var currentExplanation: Explanation
    
    var body: some View {
        Button {
            currentExplanation = Explanation(title: title, description: description, show: true)
        } label: {
            Image(systemName: "info.circle") // or "questionmark.circle"?
        }
    }
}

#Preview {
    ExplanationInfoButton(title: "", description: "", currentExplanation: .constant(Explanation(title: "", description: "", show: false)))
}
