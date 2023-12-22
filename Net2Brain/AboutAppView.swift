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
            }.navigationTitle("About this app")
                .toolbar {
                    Button("Dismiss", systemImage: "xmark") {
                        dismiss()
                    }
                }
        }
    }
}

#Preview {
    AboutAppView()
}
