//
//  ExplanationSheet.swift
//  Net2Brain
//
//  Created by Marco Weßel on 04.01.24.
//

import SwiftUI

struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// a sheet view used for displaying explanation throughout the app
/// - Parameters:
///   - title: the explanation's title
///   - description: the text of the explanation
struct ExplanationSheet: View {
    
    @Binding var sheetTitle: String
    @Binding var sheetDescription: String
    
    @State private var sheetHeight: CGFloat = .zero
    
    var body: some View {
        /// https://stackoverflow.com/a/74495460 ; 04.01.24 12:31
        VStack(alignment: .leading) {
            Text(String(localized: String.LocalizationValue(sheetTitle))).font(.title2).padding(.bottom, 6).fixedSize(horizontal: false, vertical: true)
            Text(.init(String(localized: String.LocalizationValue(sheetDescription)))).fixedSize(horizontal: false, vertical: true)
        }.padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .overlay {
                GeometryReader { geometry in
                    Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                }
            }
            .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                sheetHeight = newHeight
            }
            .presentationDetents([.height(sheetHeight)])
            .presentationBackground(.thinMaterial)
            .presentationCornerRadius(16.0)
    }
}

#Preview {
    ExplanationSheet(sheetTitle: .constant(""), sheetDescription: .constant(""))
}
