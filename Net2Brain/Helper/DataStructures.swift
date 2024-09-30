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

/// used for navigation in the app
enum MenuTargetView {
    case visualizeRoi, visualizeFmri, imageOverview, prediction, history, glossary
}

/// used for choosing the type of brain visualization
enum VisualizationType {
    case brain, brainWithImage
}

/// used for choosing the hemisphere for brain visualization
enum Hemisphere {
    case left, right
}

/// enumeration for all available ROIs (mainly used for brain visualization)
enum ROI: String {
    case all = "all"
    case visual = "visual"
    case body = "body"
    case face = "face"
    case place = "place"
    case word = "word"
    case anatomical = "anatomical"
}

/// enumeration used for navigation in the pipeline
enum PipelineView {
    case datasetImages, mlModel, mlLayers, rdmMetric, evaluationType, rsaChart
}

/// https://www.hackingwithswift.com/books/ios-swiftui/using-state-with-classes; 28.11.2023 08:36
/// the pipeline parameters save all parameters for the RDM comparison pipeline
/// - Parameters:
///   - dataset: the selected dataset
///   - datasetImages: array of all images selected (the file-names)
///   - mlModel: the selected ML model
///   - mlModelLayers: array of all selected model layers for the model
///   - rdmMetric: the selected RDM Metric
///   - evaluationType: the selected evaluation type
///   - evaluationParameter: the selected evaluation parameter corresponding to the evaluation type
//@Observable
class PipelineParameters: ObservableObject {
    @Published var dataset: N2BDataset
    @Published var datasetImages: [String]
    @Published var mlModel: N2BMLModel
    @Published var mlModelLayers: [N2BMLLayer]
    @Published var rdmMetric: N2BRDMMetric
    @Published var evaluationType: N2BEvaluationType
    @Published var evaluationParameter: N2BEvaluationParameter
    
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
    
    /// deselects all selected images
    func resetDatasetImages() {
        if self.datasetImages.count != 0 {
            self.datasetImages.removeAll()
        }
    }
    
    /// deselects all selected ML Model layers
    func resetMLModelLayers() {
        if self.mlModelLayers.count != 0 {
            self.mlModelLayers.removeAll()
        }
    }
    
    /// resets all parameters to standard values
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

/// used in the `PipelineSelectionView` to highlight the parameter currently being selected
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

/// struct for a image category
/// - Parameters:
///   - name: name for the image category (displayed to the user)
///   - images: array of all images contained in the category with their file-names
struct N2BImageCategory: Codable, Hashable {
    var name: String
    var images: [String]
}

/// struct for a dataset
/// - Parameters:
///   - name: name of that dataset, displayed to the user
///   - datasetDescription: discription for that dataset, explanation for the user
///   - images: array of image categories corresponding to the dataset
struct N2BDataset: Codable, Hashable {
    var name: String
    var datasetDescription: String
    var images: [N2BImageCategory]
}

/// struct for a ML model with the most important parameters
/// - Parameters:
///   - key: key for identifiing the model for late use
///   - name: the name of the model displayed to the user
///   - modelDescription: a description of that model, explanation for the user
///   - layers: an array of all layers for that model
///   - bias: parameter applied to images before prediction
///   - scale: parameter applied to images before prediction
struct N2BMLModel: Codable, Hashable {
    var key: String
    var name: String
    var modelDescription: String
    var layers: [N2BMLLayer]
    var bias: [Float]
    var scale: [Float]
}

/// struct for a ML model layer
/// - Parameters:
///   - name: the name of that layers, displayed to the user
///   - layerDescription: a description for that layer, explanation for the user
///   - coremlKey: key of that layer in the Core ML model used to filter prediction results based on the user-selected layers
struct N2BMLLayer: Codable, Hashable {
    var name: String
    var layerDescription: String
    var coremlKey: String
}

/// struct for a RDM metric
/// - Parameters:
///   - name: name for that metric, displayed to the user
///   - metricDescription: a description for that metric, explanation for the user
struct N2BRDMMetric: Codable, Hashable {
    var name: String
    var metricDescription: String
}

/// struct for a evaluation type
/// - Parameters:
///   - name: name for that evaluation type, displayed to the user
///   - typeDescription: a description for that evaluation type, explanation for the user
///   - parameters: an array with all evaluation parameters available for the evaluation type
struct N2BEvaluationType: Codable, Hashable {
    var name: String
    var typeDescription: String
    var parameters: [N2BEvaluationParameter]
}

/// struct for a evaluation parameter
/// - Parameters:
///   - name: name for that evaluation parameter, displayed to the user
///   - parameterDescription: a description for that evaluation parameter, explanation for the user
struct N2BEvaluationParameter: Codable, Hashable {
    var name: String
    var parameterDescription: String
}

/// the pipeline data saves all data generated in the pipeline and used in the different views for analysis
/// - Parameters:
///   - mlPredictionOutputs: dictionary of the prediction output for every ML model layer (key is the layer's key)
///   - distanceMatrices: dictionary of the RDM matrix for every ML model layer (key is the layer's key)
///   - allRoisOutput: an array with the outputs of RSA calculation
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

/// enumeration for the current status of a running prediction
enum PredictionStatus {
    case none, predicting, processingData
}

/// enumeration for the current status of a running RSA calculation
enum RSAStatus {
    case none, loadingData, calculatingRSA
}

/// struct for the output of the RSA calculation
/// - Parameters:
///   - roi: name and index of the ROI
///   - layer: the key for the layer
///   - model: the name of the used ML model
///   - r2: the R^2 correlation value
///   - significance: the significance value
///   - sem: standard error of the mean value
struct RSAOutput: Codable, Hashable {
    var roi: String
    var layer: String
    var model: String
    var r2: Float
    var significance: Float
    var sem: Float
}

/// enumeration with all in the contained ML models
/*enum MLModelName {
    case alexnet, resnet18, resnet34, resnet50, vgg11, vgg13
}*/

// data types for experiment history
struct SimpleMatrix: Codable, Hashable {
    var layerName: String
    var data: [Float]
    var shape: [Int]
}

@Model
final class HistoryPipelineParameters {
    @Attribute(.unique) var id: UUID
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
    @Attribute(.unique) var id: UUID
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
