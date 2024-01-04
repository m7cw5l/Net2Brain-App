//
//  AvailableData.swift
//  Net2Brain
//
//  Created by Marco Weßel on 04.12.23.
//

import Foundation

let availableDatasets = [
    N2BDataset(name: String(localized: "pipeline.datasets.78images.title"), description: String(localized: "pipeline.datasets.78images.description"), images: (1...78).map { String(format: "78images_%05d", $0) }),
    N2BDataset(name: String(localized: "pipeline.datasets.92images.title"), description: String(localized: "pipeline.datasets.92images.description"), images: (1...92).map { String(format: "92images_%05d", $0) })
]


let alexnetLayers = [
    N2BMLLayer(name: "features.0", description: "1 x 64 x 55 x 55", coremlKey: "features_0"),
    N2BMLLayer(name: "features.3", description: "1 x 192 x 27 x 27", coremlKey: "features_3"),
    N2BMLLayer(name: "features.6", description: "1 x 384 x 13 x 13", coremlKey: "features_6"),
    N2BMLLayer(name: "features.8", description: "1 x 256 x 13 x 13", coremlKey: "features_8"),
    N2BMLLayer(name: "features.10", description: "1 x 256 x 13 x 13", coremlKey: "features_10")
]
private let resnetLayers = [
    N2BMLLayer(name: "layer1", description: "1 x 64 x 56 x 56", coremlKey: "layer1"),
    N2BMLLayer(name: "layer2", description: "1 x 128 x 28 x 28", coremlKey: "layer2"),
    N2BMLLayer(name: "layer3", description: "1 x 256 x 14 x 14", coremlKey: "layer3"),
    N2BMLLayer(name: "layer4", description: "512 x 7 x 7", coremlKey: "layer4")
]
private let resnet50Layers = [
    N2BMLLayer(name: "layer1", description: "1 x 256 x 56 x 56", coremlKey: "layer1"),
    N2BMLLayer(name: "layer2", description: "1 x 512 x 28 x 28", coremlKey: "layer2"),
    N2BMLLayer(name: "layer3", description: "1 x 2014 x 14 x 14", coremlKey: "layer3"),
    N2BMLLayer(name: "layer4", description: "1 x 2048 x 7 x 7", coremlKey: "layer4")
]
private let vgg11Layers = [
    N2BMLLayer(name: "features.0", description: "1 x 64 x 224 x 224", coremlKey: "features_0"),
    N2BMLLayer(name: "features.3", description: "1 x 128 x 112 x 112", coremlKey: "features_3"),
    N2BMLLayer(name: "features.8", description: "1 x 256 x 56 x 56", coremlKey: "features_8"),
    N2BMLLayer(name: "features.13", description: "1 x 512 x 28 x 28", coremlKey: "features_13"),
    N2BMLLayer(name: "features.18", description: "1 x 512 x 14 x 14", coremlKey: "features_18")
]
private let vgg13Layers = [
    N2BMLLayer(name: "features.2", description: "1 x 64 x 224 x 224", coremlKey: "features_2"),
    N2BMLLayer(name: "features.7", description: "1 x 128 x 112 x 112", coremlKey: "features_7"),
    N2BMLLayer(name: "features.12", description: "1 x 256 x 56 x 56", coremlKey: "features_12"),
    N2BMLLayer(name: "features.17", description: "1 x 512 x 28 x 28", coremlKey: "features_17"),
    N2BMLLayer(name: "features.22", description: "1 x 512 x 14 x 14", coremlKey: "features_22")
]


let availableMLModels = [
    /// https://en.wikipedia.org/wiki/AlexNet ; 13.12.2023 09:42
    N2BMLModel(key: "alexnet", name: "AlexNet", description: String(localized: "pipeline.models.alexnet.description"), layers: alexnetLayers),
    /// https://www.mathworks.com/help/deeplearning/ref/resnet18.html ; 13.12.2023 09:45
    N2BMLModel(key: "resnet18", name: "ResNet18", description: String(localized: "pipeline.models.resnet18.description"), layers: resnetLayers),
    N2BMLModel(key: "resnet34", name: "ResNet34", description: String(localized: "pipeline.models.resnet34.description"), layers: resnetLayers),
    N2BMLModel(key: "resnet50", name: "ResNet50", description: String(localized: "pipeline.models.resnet50.description"), layers: resnet50Layers),
    /// https://arxiv.org/abs/1409.1556 ; 13.12.2023 09:49
    N2BMLModel(key: "vgg11", name: "VGG11", description: String(localized: "pipeline.models.vgg11.description"), layers: vgg11Layers),
    N2BMLModel(key: "vgg13", name: "VGG13", description: String(localized: "pipeline.models.vgg13.description"), layers: vgg13Layers)
]

let availableRDMMetrics = [
    /// https://en.wikipedia.org/wiki/Euclidean_distance ; 29.12.2023 15:44
    N2BRDMMetric(name: String(localized: "pipeline.rdm.metric.euclidean.title"), description: String(localized: "pipeline.rdm.metric.euclidean.description")),
    /// https://en.wikipedia.org/wiki/Taxicab_geometry ; 29.12.2023 15:45
    N2BRDMMetric(name: String(localized: "pipeline.rdm.metric.manhattan.title"), description: String(localized: "pipeline.rdm.metric.manhattan.description")),
    N2BRDMMetric(name: String(localized: "pipeline.rdm.metric.cosine.title"), description: String(localized: "pipeline.rdm.metric.cosine.description")),
    N2BRDMMetric(name: String(localized: "pipeline.rdm.metric.correlation.title"), description: String(localized: "pipeline.rdm.metric.correlation.description"))
]

let availableEvaluationTypes = [
    /// https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient ; 29.12.2023 15:51
    N2BEvaluationType(name: String(localized: "pipeline.evaluation.types.rsa.title"), description: String(localized: "pipeline.evaluation.types.rsa.description"), parameters: [N2BEvaluationParameter(name: String(localized: "pipeline.evaluation.parameters.spearman.title"), description: String(localized: "pipeline.evaluation.parameters.spearman.description"))])
]
