//
//  HeatmapTabView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 29.11.23.
//

import SwiftUI
import Matft

struct HeatmapTabView: View {
    
    var matrices: [MfArray]
    
    var body: some View {
        TabView {
            ForEach(0..<matrices.count, id: \.self) { index in
                HeatmapChart(matrix: matrices[index], images: [])
            }
        }.tabViewStyle(.automatic)
            .padding()
            .background()
                .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    let matrix = MfArray((1...100).map { _ in Float.random(in: 0...1) }, shape: [10, 10])
    let matrix2 = MfArray((1...400).map { _ in Float.random(in: 0...1) }, shape: [20, 20])
    return HeatmapTabView(matrices: [matrix, matrix2])
}
