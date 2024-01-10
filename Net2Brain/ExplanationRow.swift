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

struct ExplanationRow: View {
    
    @State var title: String
    @State var description: String
    
    @Binding var currentExplanation: Explanation
    
    var body: some View {
        /// https://stackoverflow.com/a/68346724 ; 04.01.24 12:23
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
    ExplanationRow(title: "", description: "", currentExplanation: .constant(Explanation(title: "", description: "", show: false)))
}
