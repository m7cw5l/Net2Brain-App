//
//  DataStructures.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import Foundation
import SwiftUI
import Matft
import SwiftData

enum MenuTargetView {
    case visualizeRoi, visualizeFmri, imageOverview, prediction, history, glossary
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
enum PipelineView {
    case datasetImages, mlModel, mlLayers, rdmMetric, evaluationType, rsaChart
}

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
        self.dataset = N2BDataset(name: "", datasetDescription: "", images: [])
        self.datasetImages = []
        self.mlModel = N2BMLModel(key: "", name: "", modelDescription: "", layers: [], bias: [], scale: [])
        self.mlModelLayers = []
        self.rdmMetric = N2BRDMMetric(name: "", metricDescription: "")
        self.evaluationType = N2BEvaluationType(name: "", typeDescription: "", parameters: [])
        self.evaluationParameter = N2BEvaluationParameter(name: "", parameterDescription: "")
    }
    
    init(historyPipelineParameters: HistoryPipelineParameters) {
        self.dataset = historyPipelineParameters.dataset
        self.datasetImages = historyPipelineParameters.datasetImages
        self.mlModel = historyPipelineParameters.mlModel
        self.mlModelLayers = historyPipelineParameters.mlModelLayers
        self.rdmMetric = historyPipelineParameters.rdmMetric
        self.evaluationType = historyPipelineParameters.evaluationType
        self.evaluationParameter = historyPipelineParameters.evaluationParameter
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
    
    func resetAll() {
        self.dataset = N2BDataset(name: "", datasetDescription: "", images: [])
        resetDatasetImages()
        self.mlModel = N2BMLModel(key: "", name: "", modelDescription: "", layers: [], bias: [], scale: [])
        resetMLModelLayers()
        self.rdmMetric = N2BRDMMetric(name: "", metricDescription: "")
        self.evaluationType = N2BEvaluationType(name: "", typeDescription: "", parameters: [])
        self.evaluationParameter = N2BEvaluationParameter(name: "", parameterDescription: "")
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

struct N2BImageCategory: Codable, Hashable {
    var name: String
    var images: [String]
}

struct N2BDataset: Codable, Hashable {
    var name: String
    var datasetDescription: String
    var images: [N2BImageCategory]
}

struct N2BMLModel: Codable, Hashable {
    var key: String
    var name: String
    var modelDescription: String
    var layers: [N2BMLLayer]
    var bias: [Float]
    var scale: [Float]
}

struct N2BMLLayer: Codable, Hashable {
    var name: String
    var layerDescription: String
    var coremlKey: String
}

struct N2BRDMMetric: Codable, Hashable {
    var name: String
    var metricDescription: String
    //var function: (() -> Void)
}

struct N2BEvaluationType: Codable, Hashable {
    var name: String
    var typeDescription: String
    var parameters: [N2BEvaluationParameter]
}

struct N2BEvaluationParameter: Codable, Hashable {
    var name: String
    var parameterDescription: String
}

class PipelineData: ObservableObject {
    @Published var mlPredictionOutputs: [String:MfArray]
    @Published var distanceMatrices: [String:MfArray]
    @Published var allRoisOutput: [RSAOutput]
    
    init(mlPredictionOutputs: [String:MfArray], distanceMatrices: [String:MfArray], allRoisOutput: [RSAOutput]) {
        self.mlPredictionOutputs = mlPredictionOutputs
        self.distanceMatrices = distanceMatrices
        self.allRoisOutput = allRoisOutput
    }
    
    init() {
        self.mlPredictionOutputs = [:]
        self.distanceMatrices = [:]
        self.allRoisOutput = []
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
    
    func resetRoiOutputs() {
        if self.allRoisOutput.count != 0 {
            self.allRoisOutput.removeAll()
        }
    }
    
    func resetAll() {
        resetPredictionOutputs()
        resetDistanceMatrices()
        resetRoiOutputs()
    }
}

enum PredictionStatus {
    case none, predicting, processingData
}

enum RSAStatus {
    case none, loadingData, calculatingRSA
}

struct RSAOutput: Codable, Hashable {
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

// data types for experiment history
struct SimpleMatrix: Codable, Hashable {
    var layerName: String
    var data: [Float]
    var shape: [Int]
}

@Model
final class HistoryPipelineParameters {
    @Attribute(.unique) let id: UUID
    var dataset: N2BDataset
    var datasetImages: [String]
    var mlModel: N2BMLModel
    var mlModelLayers: [N2BMLLayer]
    var rdmMetric: N2BRDMMetric
    var evaluationType: N2BEvaluationType
    var evaluationParameter: N2BEvaluationParameter
    
    init(dataset: N2BDataset, datasetImages: [String], mlModel: N2BMLModel, mlModelLayers: [N2BMLLayer], rdmMetric: N2BRDMMetric, evaluationType: N2BEvaluationType, evaluationParameter: N2BEvaluationParameter) {
        self.id = UUID()
        self.dataset = dataset
        self.datasetImages = datasetImages
        self.mlModel = mlModel
        self.mlModelLayers = mlModelLayers
        self.rdmMetric = rdmMetric
        self.evaluationType = evaluationType
        self.evaluationParameter = evaluationParameter
    }
    
    init(pipelineParameters: PipelineParameters) {
        self.id = UUID()
        self.dataset = pipelineParameters.dataset
        self.datasetImages = pipelineParameters.datasetImages
        self.mlModel = pipelineParameters.mlModel
        self.mlModelLayers = pipelineParameters.mlModelLayers
        self.rdmMetric = pipelineParameters.rdmMetric
        self.evaluationType = pipelineParameters.evaluationType
        self.evaluationParameter = pipelineParameters.evaluationParameter
    }
}

@Model
final class HistoryEntry {
    @Attribute(.unique) let id: UUID
    var date: Date
    var pipelineParameters: HistoryPipelineParameters
    var distanceMatrices: [SimpleMatrix]
    var roiOutput: [RSAOutput]
    
    init(date: Date, pipelineParameter: HistoryPipelineParameters, distanceMatrices: [SimpleMatrix], roiOutput: [RSAOutput]) {
        self.id = UUID()
        self.date = date
        self.pipelineParameters = pipelineParameter
        self.distanceMatrices = distanceMatrices
        self.roiOutput = roiOutput
    }
    
    init() {
        self.id = UUID()
        self.date = Date()
        self.pipelineParameters = HistoryPipelineParameters(pipelineParameters: PipelineParameters())
        self.distanceMatrices = []
        self.roiOutput = []
    }
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
