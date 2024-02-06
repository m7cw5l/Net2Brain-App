//
//  AvailableData.swift
//  Net2Brain
//
//  Created by Marco Weßel on 04.12.23.
//

import Foundation


let images78 = [
    N2BImageCategory(name: "pipeline.image.category.animals", images: (1...13).map { String(format: "78images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.plants", images: (14...21).map { String(format: "78images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.food", images: (22...29).map { String(format: "78images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.office", images: (30...32).map { String(format: "78images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.rooms", images: (33...38).map { String(format: "78images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.city", images: (39...45).map { String(format: "78images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.landscape", images: (46...50).map { String(format: "78images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.sports", images: (51...61).map { String(format: "78images_%05d", $0) }),
    //N2BImageCategory(name: "pipeline.image.category.unknown", images: (62...62).map { String(format: "78images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.faces", images: (62...78).map { String(format: "78images_%05d", $0) })
]

let images92 = [
    N2BImageCategory(name: "pipeline.image.category.body", images: (1...12).map { String(format: "92images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.faces", images: (13...24).map { String(format: "92images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.animals", images: (25...48).map { String(format: "92images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.nature.food", images: (49...72).map { String(format: "92images_%05d", $0) }),
    N2BImageCategory(name: "pipeline.image.category.everyday.items", images: (73...92).map { String(format: "92images_%05d", $0) })
]

let availableDatasets = [
    N2BDataset(name: String(localized: "pipeline.datasets.78images.title"), datasetDescription: String(localized: "pipeline.datasets.78images.description"), images: images78),
    N2BDataset(name: String(localized: "pipeline.datasets.92images.title"), datasetDescription: String(localized: "pipeline.datasets.92images.description"), images: images92)
]

let alexnetLayers = [
    N2BMLLayer(name: "features.0", layerDescription: "1 x 64 x 55 x 55", coremlKey: "features_0"),
    N2BMLLayer(name: "features.3", layerDescription: "1 x 192 x 27 x 27", coremlKey: "features_3"),
    N2BMLLayer(name: "features.6", layerDescription: "1 x 384 x 13 x 13", coremlKey: "features_6"),
    N2BMLLayer(name: "features.8", layerDescription: "1 x 256 x 13 x 13", coremlKey: "features_8"),
    N2BMLLayer(name: "features.10", layerDescription: "1 x 256 x 13 x 13", coremlKey: "features_10")
]
private let resnetLayers = [
    N2BMLLayer(name: "layer1", layerDescription: "1 x 64 x 56 x 56", coremlKey: "layer1"),
    N2BMLLayer(name: "layer2", layerDescription: "1 x 128 x 28 x 28", coremlKey: "layer2"),
    N2BMLLayer(name: "layer3", layerDescription: "1 x 256 x 14 x 14", coremlKey: "layer3"),
    N2BMLLayer(name: "layer4", layerDescription: "512 x 7 x 7", coremlKey: "layer4")
]
private let resnet50Layers = [
    N2BMLLayer(name: "layer1", layerDescription: "1 x 256 x 56 x 56", coremlKey: "layer1"),
    N2BMLLayer(name: "layer2", layerDescription: "1 x 512 x 28 x 28", coremlKey: "layer2"),
    N2BMLLayer(name: "layer3", layerDescription: "1 x 2014 x 14 x 14", coremlKey: "layer3"),
    N2BMLLayer(name: "layer4", layerDescription: "1 x 2048 x 7 x 7", coremlKey: "layer4")
]
private let vgg11Layers = [
    N2BMLLayer(name: "features.0", layerDescription: "1 x 64 x 224 x 224", coremlKey: "features_0"),
    N2BMLLayer(name: "features.3", layerDescription: "1 x 128 x 112 x 112", coremlKey: "features_3"),
    N2BMLLayer(name: "features.8", layerDescription: "1 x 256 x 56 x 56", coremlKey: "features_8"),
    N2BMLLayer(name: "features.13", layerDescription: "1 x 512 x 28 x 28", coremlKey: "features_13"),
    N2BMLLayer(name: "features.18", layerDescription: "1 x 512 x 14 x 14", coremlKey: "features_18")
]
private let vgg13Layers = [
    N2BMLLayer(name: "features.2", layerDescription: "1 x 64 x 224 x 224", coremlKey: "features_2"),
    N2BMLLayer(name: "features.7", layerDescription: "1 x 128 x 112 x 112", coremlKey: "features_7"),
    N2BMLLayer(name: "features.12", layerDescription: "1 x 256 x 56 x 56", coremlKey: "features_12"),
    N2BMLLayer(name: "features.17", layerDescription: "1 x 512 x 28 x 28", coremlKey: "features_17"),
    N2BMLLayer(name: "features.22", layerDescription: "1 x 512 x 14 x 14", coremlKey: "features_22")
]


let availableMLModels = [
    /// https://en.wikipedia.org/wiki/AlexNet ; 13.12.2023 09:42
    N2BMLModel(key: "alexnet", name: "AlexNet", modelDescription: String(localized: "pipeline.models.alexnet.description"), layers: alexnetLayers, bias: [0.485, 0.456, 0.406, 0.0], scale: [0.229, 0.224, 0.225, 1.0]),
    /// https://www.mathworks.com/help/deeplearning/ref/resnet18.html ; 13.12.2023 09:45
    N2BMLModel(key: "resnet18", name: "ResNet18", modelDescription: String(localized: "pipeline.models.resnet18.description"), layers: resnetLayers, bias: [0.485, 0.456, 0.406, 0.0], scale: [0.229, 0.224, 0.225, 1.0]),
    N2BMLModel(key: "resnet34", name: "ResNet34", modelDescription: String(localized: "pipeline.models.resnet34.description"), layers: resnetLayers, bias: [0.485, 0.456, 0.406, 0.0], scale: [0.229, 0.224, 0.225, 1.0]),
    N2BMLModel(key: "resnet50", name: "ResNet50", modelDescription: String(localized: "pipeline.models.resnet50.description"), layers: resnet50Layers, bias: [0.485, 0.456, 0.406, 0.0], scale: [0.229, 0.224, 0.225, 1.0]),
    /// https://arxiv.org/abs/1409.1556 ; 13.12.2023 09:49
    N2BMLModel(key: "vgg11", name: "VGG11", modelDescription: String(localized: "pipeline.models.vgg11.description"), layers: vgg11Layers, bias: [0.485, 0.456, 0.406, 0.0], scale: [0.229, 0.224, 0.225, 1.0]),
    N2BMLModel(key: "vgg13", name: "VGG13", modelDescription: String(localized: "pipeline.models.vgg13.description"), layers: vgg13Layers, bias: [0.485, 0.456, 0.406, 0.0], scale: [0.229, 0.224, 0.225, 1.0])
]

let availableRDMMetrics = [
    /// https://en.wikipedia.org/wiki/Euclidean_distance ; 29.12.2023 15:44
    N2BRDMMetric(name: String(localized: "pipeline.rdm.metric.euclidean.title"), metricDescription: String(localized: "pipeline.rdm.metric.euclidean.description")),
    /// https://en.wikipedia.org/wiki/Taxicab_geometry ; 29.12.2023 15:45
    N2BRDMMetric(name: String(localized: "pipeline.rdm.metric.manhattan.title"), metricDescription: String(localized: "pipeline.rdm.metric.manhattan.description")),
    N2BRDMMetric(name: String(localized: "pipeline.rdm.metric.cosine.title"), metricDescription: String(localized: "pipeline.rdm.metric.cosine.description")),
    N2BRDMMetric(name: String(localized: "pipeline.rdm.metric.correlation.title"), metricDescription: String(localized: "pipeline.rdm.metric.correlation.description"))
]

let availableEvaluationTypes = [
    /// https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient ; 29.12.2023 15:51
    N2BEvaluationType(name: String(localized: "pipeline.evaluation.types.rsa.title"), typeDescription: String(localized: "pipeline.evaluation.types.rsa.description"), parameters: [N2BEvaluationParameter(name: String(localized: "pipeline.evaluation.parameters.spearman.title"), parameterDescription: String(localized: "pipeline.evaluation.parameters.spearman.description"))])
]
