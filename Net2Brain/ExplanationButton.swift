//
//  ExplanationButton.swift
//  Net2Brain
//
//  Created by Marco Weßel on 04.01.24.
//

import SwiftUI

struct Explanation {
    var title: String
    var description: String
    var show: Bool
}

struct ExplanationButton: View {
    
    @State var title: String
    @State var description: String
    
    @Binding var currentExplanation: Explanation
    
    var body: some View {
        Button(action: {
            currentExplanation = Explanation(title: title, description: description, show: true)
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(String(localized: String.LocalizationValue(title))).foregroundColor(.primary)
                }
            }
        })
    }
}

#Preview {
    ExplanationButton(title: "", description: "", currentExplanation: .constant(Explanation(title: "", description: "", show: false)))
}
