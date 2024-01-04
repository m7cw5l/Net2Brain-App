//
//  AboutAppView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 24.10.23.
//

import SwiftUI

struct AboutAppView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Text("Hello, World!")
            }.navigationTitle("view.about.title")
                .toolbar {
                    Button("button.dismiss.title", systemImage: "xmark") {
                        dismiss()
                    }
                }
        }
    }
}

#Preview {
    AboutAppView()
}
