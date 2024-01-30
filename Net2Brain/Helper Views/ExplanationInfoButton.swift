//
//  ExplanationInfoButton.swift
//  Net2Brain
//
//  Created by Marco Weßel on 09.01.24.
//

import SwiftUI

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
