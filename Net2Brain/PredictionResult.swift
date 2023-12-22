//
//  PredictionResult.swift
//  Net2Brain
//
//  Created by Marco Weßel on 12.12.23.
//

import Foundation
import SwiftData

@Model
final class PredictionResult {
    let id: UUID
    let model: String
    let layer: String
    let data: [Float]
    let shape: [Int]
    
    init(model: String, layer: String, data: [Float], shape: [Int]) {
        self.id = UUID()
        self.model = model
        self.layer = layer
        self.data = data
        self.shape = shape
    }
}
