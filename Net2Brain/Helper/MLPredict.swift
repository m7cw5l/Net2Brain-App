//
//  MLPredict.swift
//  Net2Brain
//
//  Created by Marco Weßel on 26.10.23.
//

import SwiftUI
import CoreML
import Matft

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: targetSize.width,
            height: targetSize.height
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}

struct MLPredict {
    private let pathImages = Bundle.main.resourcePath!
        
    func loadImage(_ name: String) -> UIImage {
        return UIImage(contentsOfFile: "\(pathImages)/\(name).jpg") ?? UIImage()
    }
    
    func loadCGImage(_ name: String, width: Int = 224, height: Int = 224, bias: [Float], scale: [Float]) -> CGImage {
        //let cgImage = (UIImage(contentsOfFile: "\(pathImages)/\(name).jpg") ?? UIImage()).resize(targetSize: CGSize(width: width, height: height)).cgImage!
        let cgImage = (UIImage(contentsOfFile: "\(pathImages)/\(name).jpg") ?? UIImage()).cgImage!
        let image = Matft.image.cgimage2mfarray(cgImage, mftype: .Float)
        let resizedImage = Matft.image.resize(image, width: width, height: height)
                
        let bias = Matft.broadcast_to(MfArray([0.485, 0.456, 0.406, 0.0], mftype: .Float), shape: resizedImage.shape)
        let scale = Matft.broadcast_to(MfArray([0.229, 0.224, 0.225, 1.0], mftype: .Float), shape: resizedImage.shape)
        
        let scaledImage = (resizedImage - bias) / scale
                        
        return Matft.image.mfarray2cgimage(scaledImage)
    }
    
    /*func loadImageFromUrl(_ urlString: String, completionHandler: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: urlString) else { return completionHandler(nil) }
        KingfisherManager.shared.retrieveImage(with: KF.ImageResource(downloadURL: url), completionHandler: { result in
            switch result {
            case .success(let value):
                completionHandler(value.image)
            case .failure(let error):
                print(error)
                completionHandler(nil)
            }
        })
    }*/
    
    func buffer(from image: UIImage, width: Int = 224, height: Int = 224) -> CVPixelBuffer? {
        let inputImage = image.resize(targetSize: CGSize(width: width, height: height))
        
        ///https://www.hackingwithswift.com/whats-new-in-ios-11; 26.10.23 08:43
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(inputImage.size.width), Int(inputImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else { return nil }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(inputImage.size.width), height: Int(inputImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: inputImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        inputImage.draw(in: CGRect(x: 0, y: 0, width: inputImage.size.width, height: inputImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func unpackFeature(_ feature: MLFeatureValue) -> MfArray {
        guard var featureMultiArray = feature.multiArrayValue else { return MfArray([-1]) }
        return MfArray(base: &featureMultiArray).flatten().expand_dims(axis: 0)
    }
    
    func predictAlexNet(imageNames: [String], selectedModel: N2BMLModel, layers: [String], progressCallback: (_ status: PredictionStatus, _ progress: Double)->()) async -> [String:MfArray] {
        guard let model = try? alexnet() else {
            fatalError()
        }
        
        progressCallback(.predicting, 0.1)
        let inputArray: [alexnetInput] = imageNames.map { imageName in
            guard let input = try? alexnetInput(imageWith: loadCGImage(imageName, bias: selectedModel.bias, scale: selectedModel.scale)) else { fatalError() }
            return input
        }
        progressCallback(.predicting, 0.2)
        guard let predictions = try? model.predictions(inputs: inputArray) else { fatalError() }
        progressCallback(.processingData, 0.3)
        
        let totalCount = Double(layers.count * predictions.count)
        var currentIndex = 0.0
        let layerOutput = layers.reduce(into: [String:MfArray]()) { dict, layer in
            let unpackedFeatures = predictions.map { prediction in
                guard let feature = prediction.featureValue(for: layer) else { fatalError() }
                let unpackedFeature = unpackFeature(feature)
                currentIndex += 1
                progressCallback(.processingData, 0.3 + (currentIndex / totalCount) * 0.7)
                return unpackedFeature
            }
            dict[layer] = Matft.vstack(unpackedFeatures)//.expand_dims(axis: 0)
        }
        
        return layerOutput
    }
    
    func predictResNet18(imageNames: [String], selectedModel: N2BMLModel, layers: [String], progressCallback: (_ status: PredictionStatus, _ progress: Double)->()) async -> [String:MfArray] {
        guard let model = try? resnet18() else {
            fatalError()
        }
        
        progressCallback(.predicting, 0.1)
        let inputArray: [resnet18Input] = imageNames.map { imageName in
            guard let input = try? resnet18Input(imageWith: loadCGImage(imageName, bias: selectedModel.bias, scale: selectedModel.scale)) else { fatalError() }
            return input
        }
        progressCallback(.predicting, 0.2)
        guard let predictions = try? model.predictions(inputs: inputArray) else { fatalError() }
        progressCallback(.processingData, 0.3)
        
        let totalCount = Double(layers.count * predictions.count)
        var currentIndex = 0.0
        let layerOutput = layers.reduce(into: [String:MfArray]()) { dict, layer in
            let unpackedFeatures = predictions.map { prediction in
                guard let feature = prediction.featureValue(for: layer) else { fatalError() }
                let unpackedFeature = unpackFeature(feature)
                currentIndex += 1
                progressCallback(.processingData, 0.3 + (currentIndex / totalCount) * 0.7)
                return unpackedFeature
            }
            dict[layer] = Matft.vstack(unpackedFeatures)//.expand_dims(axis: 0)
        }
        
        return layerOutput
    }
    
    func predictResNet34(imageNames: [String], selectedModel: N2BMLModel, layers: [String], progressCallback: (_ status: PredictionStatus, _ progress: Double)->()) async -> [String:MfArray] {
        guard let model = try? resnet34() else {
            fatalError()
        }
        
        progressCallback(.predicting, 0.1)
        let inputArray: [resnet34Input] = imageNames.map { imageName in
            guard let input = try? resnet34Input(imageWith: loadCGImage(imageName, bias: selectedModel.bias, scale: selectedModel.scale)) else { fatalError() }
            return input
        }
        progressCallback(.predicting, 0.2)
        guard let predictions = try? model.predictions(inputs: inputArray) else { fatalError() }
        progressCallback(.processingData, 0.3)
        
        let totalCount = Double(layers.count * predictions.count)
        var currentIndex = 0.0
        let layerOutput = layers.reduce(into: [String:MfArray]()) { dict, layer in
            let unpackedFeatures = predictions.map { prediction in
                guard let feature = prediction.featureValue(for: layer) else { fatalError() }
                let unpackedFeature = unpackFeature(feature)
                currentIndex += 1
                progressCallback(.processingData, 0.3 + (currentIndex / totalCount) * 0.7)
                return unpackedFeature
            }
            dict[layer] = Matft.vstack(unpackedFeatures)//.expand_dims(axis: 0)
        }
        
        return layerOutput
    }
    
    func predictResNet50(imageNames: [String], selectedModel: N2BMLModel, layers: [String], progressCallback: (_ status: PredictionStatus, _ progress: Double)->()) async -> [String:MfArray] {
        guard let model = try? resnet50() else {
            fatalError()
        }
        
        progressCallback(.predicting, 0.1)
        let inputArray: [resnet50Input] = imageNames.map { imageName in
            guard let input = try? resnet50Input(imageWith: loadCGImage(imageName, bias: selectedModel.bias, scale: selectedModel.scale)) else { fatalError() }
            return input
        }
        progressCallback(.predicting, 0.2)
        guard let predictions = try? model.predictions(inputs: inputArray) else { fatalError() }
        progressCallback(.processingData, 0.3)
        
        let totalCount = Double(layers.count * predictions.count)
        var currentIndex = 0.0
        let layerOutput = layers.reduce(into: [String:MfArray]()) { dict, layer in
            let unpackedFeatures = predictions.map { prediction in
                guard let feature = prediction.featureValue(for: layer) else { fatalError() }
                let unpackedFeature = unpackFeature(feature)
                currentIndex += 1
                progressCallback(.processingData, 0.3 + (currentIndex / totalCount) * 0.7)
                return unpackedFeature
            }
            dict[layer] = Matft.vstack(unpackedFeatures)//.expand_dims(axis: 0)
        }
        
        return layerOutput
    }
    
    func predictVgg11(imageNames: [String], selectedModel: N2BMLModel, layers: [String], progressCallback: (_ status: PredictionStatus, _ progress: Double)->()) async -> [String:MfArray] {
        guard let model = try? vgg11() else {
            fatalError()
        }
        
        progressCallback(.predicting, 0.1)
        let inputArray: [vgg11Input] = imageNames.map { imageName in
            guard let input = try? vgg11Input(imageWith: loadCGImage(imageName, bias: selectedModel.bias, scale: selectedModel.scale)) else { fatalError() }
            return input
        }
        progressCallback(.predicting, 0.2)
        guard let predictions = try? model.predictions(inputs: inputArray) else { fatalError() }
        progressCallback(.processingData, 0.3)
        
        let totalCount = Double(layers.count * predictions.count)
        var currentIndex = 0.0
        let layerOutput = layers.reduce(into: [String:MfArray]()) { dict, layer in
            let unpackedFeatures = predictions.map { prediction in
                guard let feature = prediction.featureValue(for: layer) else { fatalError() }
                let unpackedFeature = unpackFeature(feature)
                currentIndex += 1
                progressCallback(.processingData, 0.3 + (currentIndex / totalCount) * 0.7)
                return unpackedFeature
            }
            dict[layer] = Matft.vstack(unpackedFeatures)//.expand_dims(axis: 0)
        }
        
        return layerOutput
    }
    
    func predictVgg13(imageNames: [String], selectedModel: N2BMLModel, layers: [String], progressCallback: (_ status: PredictionStatus, _ progress: Double)->()) async -> [String:MfArray] {
        guard let model = try? vgg13() else {
            fatalError()
        }
        progressCallback(.predicting, 0.1)
        let inputArray: [vgg13Input] = imageNames.map { imageName in
            guard let input = try? vgg13Input(imageWith: loadCGImage(imageName, bias: selectedModel.bias, scale: selectedModel.scale)) else { fatalError() }
            return input
        }
        progressCallback(.predicting, 0.2)
        guard let predictions = try? model.predictions(inputs: inputArray) else { fatalError() }
        progressCallback(.processingData, 0.3)
        
        let totalCount = Double(layers.count * predictions.count)
        var currentIndex = 0.0
        let layerOutput = layers.reduce(into: [String:MfArray]()) { dict, layer in
            let unpackedFeatures = predictions.map { prediction in
                guard let feature = prediction.featureValue(for: layer) else { fatalError() }
                let unpackedFeature = unpackFeature(feature)
                currentIndex += 1
                progressCallback(.processingData, 0.3 + (currentIndex / totalCount) * 0.7)
                return unpackedFeature
            }
            dict[layer] = Matft.vstack(unpackedFeatures)//.expand_dims(axis: 0)
        }
        
        return layerOutput
    }
    
    /*func predictResNet18(imageNames: [String], layers: [String]) async -> [MfArray] {
        guard let model = try? resnet18() else {
            fatalError()
        }
        
        var allLayerOutputs = [MfArray]()
        
        for layer in layers {
            var layerOutputArray = [MfArray]()
            
            for imageName in imageNames {
                let inputImage = loadImage(imageName)
                guard let pixelBuffer = buffer(from: inputImage) else { return [] }
                
                let input = resnet18Input(image: pixelBuffer)
                
                guard let pred = try? await model.prediction(input: input) else {
                    fatalError()
                }
                
                guard let feature = pred.featureValue(for: layer) else { return [] }
                guard var featureMultiArray = feature.multiArrayValue else { return [] }
                
                let matftArray = MfArray(base: &featureMultiArray)
                
                if let tensorMatft = matftArray.first {
                    layerOutputArray.append(tensorMatft)
                }
            }
            
            guard let firstOutputItem = layerOutputArray.first else { return [] }
            
            let output = Matft.concatenate(layerOutputArray).reshape([imageNames.count, firstOutputItem.shape[0], firstOutputItem.shape[1], firstOutputItem.shape[2]])
            
            allLayerOutputs.append(flattenOutput(output))
        }
        
        return allLayerOutputs
    }*/
}
