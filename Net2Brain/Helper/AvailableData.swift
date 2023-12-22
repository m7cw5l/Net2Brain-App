//
//  AvailableData.swift
//  Net2Brain
//
//  Created by Marco Weßel on 04.12.23.
//

import Foundation

let availableDatasets = [
    N2BDataset(name: "78images", description: "A dataset consisting out of 78 images and the distance matrices from brain responses for all 78 images and 15 subjects", images: (1...78).map { String(format: "78images_%05d", $0) }),
    N2BDataset(name: "92images", description: "A dataset consisting out of 92 images and the distance matrices from brain responses for all 92 images and 15 subjects", images: (1...92).map { String(format: "92images_%05d", $0) })
]


let alexnetLayers = [
    N2BMLLayer(name: "features.0", description: "A descriptive text for that layer", coremlKey: "features_0"),
    N2BMLLayer(name: "features.3", description: "A descriptive text for that layer", coremlKey: "features_3"),
    N2BMLLayer(name: "features.6", description: "A descriptive text for that layer", coremlKey: "features_6"),
    N2BMLLayer(name: "features.8", description: "A descriptive text for that layer", coremlKey: "features_8"),
    N2BMLLayer(name: "features.10", description: "A descriptive text for that layer", coremlKey: "features_10")
]
private let resnetLayers = [
    N2BMLLayer(name: "layer1", description: "A descriptive text for that layer", coremlKey: "layer1"),
    N2BMLLayer(name: "layer2", description: "A descriptive text for that layer", coremlKey: "layer2"),
    N2BMLLayer(name: "layer3", description: "A descriptive text for that layer", coremlKey: "layer3"),
    N2BMLLayer(name: "layer4", description: "A descriptive text for that layer", coremlKey: "layer4")
]
private let vgg11Layers = [
    N2BMLLayer(name: "features.0", description: "A descriptive text for that layer", coremlKey: "features_0"),
    N2BMLLayer(name: "features.3", description: "A descriptive text for that layer", coremlKey: "features_3"),
    N2BMLLayer(name: "features.8", description: "A descriptive text for that layer", coremlKey: "features_8"),
    N2BMLLayer(name: "features.13", description: "A descriptive text for that layer", coremlKey: "features_13"),
    N2BMLLayer(name: "features.18", description: "A descriptive text for that layer", coremlKey: "features_18")
]
private let vgg13Layers = [
    N2BMLLayer(name: "features.2", description: "A descriptive text for that layer", coremlKey: "features_2"),
    N2BMLLayer(name: "features.7", description: "A descriptive text for that layer", coremlKey: "features_7"),
    N2BMLLayer(name: "features.12", description: "A descriptive text for that layer", coremlKey: "features_12"),
    N2BMLLayer(name: "features.17", description: "A descriptive text for that layer", coremlKey: "features_17"),
    N2BMLLayer(name: "features.22", description: "A descriptive text for that layer", coremlKey: "features_22")
]


let availableMLModels = [
    /// https://en.wikipedia.org/wiki/AlexNet ; 13.12.2023 09:42
    N2BMLModel(key: "alexnet", name: "AlexNet", description: "A convolutional neural network (CNN) designed by Alex Krizhevsky in collaboration with Ilya Sutskever and Geoffrey Hinton, who was Krizhevsky's Ph.D. advisor at the University of Toronto.\nPretrained network from pytorch.", layers: alexnetLayers),
    /// https://www.mathworks.com/help/deeplearning/ref/resnet18.html ; 13.12.2023 09:45
    N2BMLModel(key: "resnet18", name: "ResNet18", description: "A convolutional neural network (CNN) consisting out of 18 layers.\nPretrained network from pytorch.", layers: resnetLayers),
    N2BMLModel(key: "resnet34", name: "ResNet34", description: "A convolutional neural network (CNN) consisting out of 34 layers.\nPretrained network from pytorch.", layers: resnetLayers),
    N2BMLModel(key: "resnet50", name: "ResNet50", description: "A convolutional neural network (CNN) consisting out of 50 layers.\nPretrained network from pytorch.", layers: resnetLayers),
    /// https://arxiv.org/abs/1409.1556 ; 13.12.2023 09:49
    N2BMLModel(key: "vgg11", name: "VGG11", description: "A convolutional neural network (CNN) consisting out of 11 layers.\nPretrained network from pytorch.", layers: vgg11Layers),
    N2BMLModel(key: "vgg13", name: "VGG13", description: "A convolutional neural network (CNN) consisting out of 13 layers.\nPretrained network from pytorch.", layers: vgg13Layers)
]

let availableRDMMetrics = [
    N2BRDMMetric(name: "Euclidean", description: "A descriptive text for that metric"),
    N2BRDMMetric(name: "Manhattan", description: "A descriptive text for that metric"),
    N2BRDMMetric(name: "Cosine", description: "A descriptive text for that metric"),
    N2BRDMMetric(name: "Correlation", description: "A descriptive text for that metric")
]

let availableEvaluationTypes = [
    N2BEvaluationType(name: "RSA", description: "A descriptive text for that type", parameters: [N2BEvaluationParameter(name: "Spearman", description: "A descriptive text for that parameter")])
]
