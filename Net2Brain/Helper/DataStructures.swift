//
//  DataStructures.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import Foundation
import SwiftUI
import Matft

enum MenuTargetView {
    case visualizeRoi, visualizeRoiImage, imageOverview, modelAccuracy
}

enum VisualizationType {
    case brain, brainWithImage
}

enum Hemisphere {
    case left, right
}

enum ROI: String {
    case all = "all"
    case visual = "visual"
    case body = "body"
    case face = "face"
    case place = "place"
    case word = "word"
    case anatomical = "anatomical"
}


// Data Types for pipeline
/// https://www.hackingwithswift.com/books/ios-swiftui/using-state-with-classes; 28.11.2023 08:36
@Observable
class PipelineParameters {
    var dataset: N2BDataset
    var datasetImages: [String]
    var mlModel: N2BMLModel
    var mlModelLayers: [N2BMLLayer]
    var rdmMetric: N2BRDMMetric
    var evaluationType: N2BEvaluationType
    var evaluationParameter: N2BEvaluationParameter
    
    init(dataset: N2BDataset, datasetImages: [String], mlModel: N2BMLModel, mlModelLayers: [N2BMLLayer], rdmMetric: N2BRDMMetric, evaluationType: N2BEvaluationType, evaluationParameter: N2BEvaluationParameter) {
        self.dataset = dataset
        self.datasetImages = datasetImages
        self.mlModel = mlModel
        self.mlModelLayers = mlModelLayers
        self.rdmMetric = rdmMetric
        self.evaluationType = evaluationType
        self.evaluationParameter = evaluationParameter
    }
    
    init() {
        self.dataset = N2BDataset(name: "", description: "", images: [])
        self.datasetImages = []
        self.mlModel = N2BMLModel(key: "", name: "", description: "", layers: [])
        self.mlModelLayers = []
        self.rdmMetric = N2BRDMMetric(name: "", description: "")
        self.evaluationType = N2BEvaluationType(name: "", description: "", parameters: [])
        self.evaluationParameter = N2BEvaluationParameter(name: "", description: "")
    }
    
    func resetDatasetImages() {
        if self.datasetImages.count != 0 {
            self.datasetImages.removeAll()
        }
    }
    
    func resetMLModelLayers() {
        if self.mlModelLayers.count != 0 {
            self.mlModelLayers.removeAll()
        }
    }
}

enum PipelineParameter: String {
    case none = "pipeline.parameter.none"
    case dataset = "pipeline.parameter.dataset"
    case images = "pipeline.parameter.images"
    case mlModel = "pipeline.parameter.model"
    case mlModelLayer = "pipeline.parameter.model.layer"
    case rdmMetric = "pipeline.parameter.rdm"
    case evaluationType = "pipeline.parameter.evaluation.type"
    case evaluationParameter = "pipeline.parameter.evaluation.parameter"
    
    func localizedString() -> String {
        return String(localized: String.LocalizationValue(self.rawValue))
    }
}

struct N2BDataset: Hashable {
    var name: String
    var description: String
    var images: [String]
}

struct N2BMLModel: Hashable {
    var key: String
    var name: String
    var description: String
    var layers: [N2BMLLayer]
}

struct N2BMLLayer: Hashable {    
    var name: String
    var description: String
    var coremlKey: String
}

struct N2BRDMMetric: Hashable {
    var name: String
    var description: String
    //var function: (() -> Void)
}

struct N2BEvaluationType: Hashable {
    var name: String
    var description: String
    var parameters: [N2BEvaluationParameter]
}

struct N2BEvaluationParameter: Hashable {
    var name: String
    var description: String
}

class PipelineData: ObservableObject {
    @Published var mlPredictionOutputs: [String:MfArray]
    @Published var distanceMatrices: [String:MfArray]
    
    init(mlPredictionOutputs: [String:MfArray], distanceMatrices: [String:MfArray]) {
        self.mlPredictionOutputs = mlPredictionOutputs
        self.distanceMatrices = distanceMatrices
    }
    
    init() {
        self.mlPredictionOutputs = [:]
        self.distanceMatrices = [:]
    }
    
    func resetPredictionOutputs() {
        if self.mlPredictionOutputs.count != 0 {
            self.mlPredictionOutputs.removeAll()
        }
    }
    
    func resetDistanceMatrices() {
        if self.distanceMatrices.count != 0 {
            self.distanceMatrices.removeAll()
        }
    }
}

enum PredictionStatus {
    case none, predicting, processingData
}

enum RSAStatus {
    case none, loadingData, calculatingRSA
}

struct RSAOutput: Hashable {
    var roi: String
    var layer: String
    var model: String
    var r2: Float
    var significance: Float
    var sem: Float
}

enum MLModelName {
    case alexnet, resnet18, resnet34, resnet50, vgg11, vgg13
}

/*enum ROI: String {
    case all = "All ROIs"
    case visual = "Early retinotopic visual regions"
    case body = "Body-selective regions"
    case face = "Face-selective regions"
    case place = "Place-selective regions"
    case word = "Word-selective regions"
    case anatomical = "Anatomical streams"
}*/
