//
//  ExplanationMenuButton.swift
//  Net2Brain
//
//  Created by Marco Weßel on 04.01.24.
//

import SwiftUI

/// view for a button in menu that shows a explanation when tapped
/// - Parameters:
///   - buttonTitle: the titlle for the button
///   - title: the explanation's title
///   - description: the text of the explanation
struct ExplanationMenuButton: View {
    
    @State var buttonTitle = ""
    @State var title: String
    @State var description: String
    
    @Binding var currentExplanation: Explanation
    
    var body: some View {
        Button(LocalizedStringKey(buttonTitle == "" ? title : buttonTitle)) {
            currentExplanation = Explanation(title: title, description: description, show: true)
        }
    }
}

#Preview {
    ExplanationMenuButton(title: "", description: "", currentExplanation: .constant(Explanation(title: "", description: "", show: false)))
}
