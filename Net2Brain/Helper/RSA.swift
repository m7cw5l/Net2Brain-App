//
//  RSA.swift
//  Net2Brain
//
//  Created by Marco Weßel on 21.11.23.
//

import Foundation
import Matft


/// struct used for RSA calculation
/// includes all corresponding functions and methods
struct RSA {
    /// struct for reading the brain RDM files from json
    struct RdmFile: Decodable {
        var data: [Float]
        var shape: [Int]
    }
    
    /// loads the brain RDM file
    /// - Parameters:
    ///   - path: the path of the json-file that should be loaded
    /// - Returns: the loaded brain RDM
    func loadRdmFile(path: String) -> MfArray {
        let fileUrl = URL(filePath: path)
                        
        guard let jsonData = try? Data(contentsOf: fileUrl) else {
            fatalError()
        }
        
        let decompressedData: Data
        if jsonData.isGzipped {
            decompressedData = try! jsonData.gunzipped()
        } else {
            decompressedData = jsonData
        }
        
        let decoder = JSONDecoder()
        do {
            let fileData = try decoder.decode(RdmFile.self, from: decompressedData)
            return MfArray(fileData.data, mftype: .Float, shape: fileData.shape)
        } catch {
            print("JSON serialization failed")
        }
        
        
        return MfArray([-1])
    }
    
    /// loads all brain RDMs for the given dataset
    /// - Parameters:
    ///   - dataset: key of the dataset used in the current experiment
    ///   - images: the selected images
    ///   - progressCallback: a callback for updating the progress bar in the UI
    /// - Returns: a dictionary with the loaded brain RDMs, key is the RDM name
    func loadBrainRdms(dataset: String, images: [String], progressCallback: (Double)->()) async -> [String:MfArray] {
        let imageIndices = images.map {
            (Int($0.suffix(5)) ?? 0) - 1
        }
        
        let brainRdmNames = [
            "78images": ["fmri_EVC_RDMs", "fmri_IT_RDMs", "fmri_T2_EVC_RDMs", "fmri_T2_IT_RDMs", "MEG_RDMs_early", "MEG_RDMs_late", "MEG_T2_RDMs_early", "MEG_T2_RDMs_late"],
            "92images": ["fmri_EVC_RDMs", "fmri_IT_RDMs", "meg_MEG_RDMs_early", "meg_MEG_RDMs_late"]
        ]
        
        guard let resourcePath = Bundle.main.resourcePath else {
            return [:]
        }
        
        let rdmNames = brainRdmNames[dataset] ?? []
        let totalCount = Double(rdmNames.count)
        var currentIndex = 0.0
        var brainRdms = [String:MfArray]()
        for rdmName in rdmNames {
            //let dataType = String(rdmName.split(separator: "_").first ?? "")
            let brainRdm = loadRdmFile(path: "\(resourcePath)/\(dataset)_\(rdmName).gzip")
            currentIndex += 0.5
            progressCallback(currentIndex / totalCount)
            brainRdms[rdmName] = shrinkBrainRdm(brainRdm, imageIndices: imageIndices)
            currentIndex += 0.5
            progressCallback(currentIndex / totalCount)
        }
                
        return brainRdms
    }
    
    /// shrinks the brain RDM based on the selected image indices
    /// all rows and columns corresponding to not selected images are discarded
    /// - Parameters:
    ///   - brainRdm: the brain RDM to be shrunken
    ///   - imageIndices: array of the indices of the selected images
    /// - Returns: the shrunken brain RDM
    func shrinkBrainRdm(_ brainRdm: MfArray, imageIndices: [Int]) -> MfArray {
        print("INPUT", brainRdm.shape)
        let indicesArray = MfArray(imageIndices)
        if brainRdm.ndim == 3 {
            // fmri data
            var outputArray = [MfArray]()
            let batchSize = brainRdm.shape[0]
            for i in 0..<batchSize {
                let distanceMatrix = brainRdm[i]
                let shrunkenMatrix = distanceMatrix.take(indices: indicesArray, axis: 0).take(indices: indicesArray, axis: 1).expand_dims(axis: 0)
                outputArray.append(shrunkenMatrix)
            }
            let output = Matft.concatenate(outputArray)
            print("FMRI", output.shape)
            return output
        } else if brainRdm.ndim == 4 {
            // meg data
            var outputArray = [MfArray]()
            let outerBatchSize = brainRdm.shape[0]
            for i in 0..<outerBatchSize {
                var innerOutputArray = [MfArray]()
                let innerBatchSize = brainRdm.shape[1]
                for j in 0..<innerBatchSize {
                    let distanceMatrix = brainRdm[i][j]
                    let shrunkenMatrix = distanceMatrix.take(indices: indicesArray, axis: 0).take(indices: indicesArray, axis: 1).expand_dims(axis: 0)
                    innerOutputArray.append(shrunkenMatrix)
                }
                outputArray.append(Matft.concatenate(innerOutputArray).expand_dims(axis: 0))
            }
            let output = Matft.concatenate(outputArray)
            print("MEG", output.shape)
            return output
        }
        return MfArray([-1])
    }
    
    /// implements the squareform algorithm, that picks only one half of the symmetric matrix
    /// - Parameters:
    ///   - x: the input matrix
    /// - Returns: the vector with all values from the matrix
    func sq(x: MfArray) -> MfArray {
        /// https://stackoverflow.com/a/13079806 ; 06.02.2024 10:16
        let matrixShape = x.shape
        
        if matrixShape[0] == matrixShape[1] {
            var outputList = [Float]()
            for i in 0..<matrixShape[0] {
                for j in i..<matrixShape[0] {
                    if i != j {
                        outputList.append(x.item(indices: [i, j], type: Float.self))
                    }
                }
            }
            return MfArray(outputList, mftype: .Float)
        }
        
        return MfArray([-1])
    }
    
    /// ranks an array
    /// - Parameters:
    ///   - array: the input array to be ranked
    /// - Returns: the ranks for the input array
    func rankArray(_ array: MfArray) -> MfArray {
        ///https://stackoverflow.com/a/5284703 ; 04.12.2023 16:35
        let temp = array.argsort(order: .Descending)
        let ranks = Matft.nums_like(0, mfarray: temp)
        ranks[temp] = Matft.arange(start: 0, to: array.count, by: 1)
        return ranks
    }
    
    /// implements the spearman rank correlation
    /// - Parameters:
    ///   - x: first input matrix
    ///   - y: second input matrix
    /// - Returns: the correlation value as Float
    func spearman(x: MfArray, y: MfArray) -> Float {
        /// https://www.simplilearn.com/tutorials/statistics-tutorial/spearmans-rank-correlation ; 21.11.2023 11:27
                
        // Step 1: add ranks to the input arrays
        let xRanks = rankArray(x)
        let yRanks = rankArray(y)
        
        // Step 2: calculate the difference between the ranks
        let diffs = Matft.math.abs(xRanks - yRanks)
        
        // Step 3: square the differences
        let diffSquare = Matft.math.square(diffs)
        
        // Step 4:
        let n = x.shape.first ?? 0
        let differenceSum = diffSquare.sum().item(index: 0, type: Float.self)
        let nenner = n * (n * n - 1)
        let result = 1 - ((Float(6) * differenceSum) / Float(nenner))
        
        return result
    }
    
    /// calculates the distance of the model RDM and every brain RDM
    /// - Parameters:
    ///   - modelRdm: the RDM from the selected model and one of it's layers
    ///   - rdms: array of all brain RDMs
    /// - Returns: a list of correlation values for every model RDM <-> brain RDM combination
    func distance(modelRdm: MfArray, rdms: MfArray) -> MfArray {
        //let modelRdmVector = modelRdm.flatten()
        let modelRdmVector = sq(x: modelRdm)
        //print(modelRdmVector.shape)
        var corrList = [Float]()
        for rdm in rdms {
            //let rdmVector = rdm.flatten()
            let rdmVector = sq(x: rdm)
            
            //let spearmanResult = spearman(x: modelRdm, y: rdm)
            let spearmanResult = spearman(x: modelRdmVector, y: rdmVector)
            corrList.append(spearmanResult)
        }
        
        return MfArray(corrList)
    }
    
    /// calculates RSA for MEG brain data
    /// - Parameters:
    ///   - modelRdm: the RDM from the selected model and one of it's layers
    ///   - brainRdm: the brain RDM used for calculating RSA
    /// - Returns: the statistical values calculated in RSA
    func rsaMeg(modelRdm: MfArray, brainRdm: MfArray) -> (r2: Float, significance: Float, sem: Float, corrSquared: MfArray) {
        
        // calculate correlation
        let distances = MfArray(brainRdm.map({ rdm in
            distance(modelRdm: modelRdm, rdms: rdm).toFlattenArray(datatype: Float.self, { $0 })
        }), mftype: .Float)
        let corr = Matft.stats.mean(distances, axis: 1)
        
        let corrSquared = Matft.math.square(corr)
                
        let r2 = Matft.stats.mean(corrSquared).item(index: 0, type: Float.self)
        
        let stats = Statistic()
        let significance = stats.tTest1Samp(corrSquared, popMean: 0)
        
        let mean = r2
        let sem = stats.sem(x: corrSquared, mean: mean)
        
        return (r2: r2, significance: significance, sem: sem, corrSquared: corrSquared)
    }
    
    /// calculates RSA for fMRI brain data
    /// - Parameters:
    ///   - modelRdm: the RDM from the selected model and one of it's layers
    ///   - brainRdm: the brain RDM used for calculating RSA
    /// - Returns: the statistical values calculated in RSA
    func rsaFmri(modelRdm: MfArray, brainRdm: MfArray) -> (r2: Float, significance: Float, sem: Float, corrSquared: MfArray) {
        let corr = distance(modelRdm: modelRdm, rdms: brainRdm)
        
        let corrSquared = Matft.math.square(corr)
                
        let r2 = Matft.stats.mean(corrSquared).item(index: 0, type: Float.self)
        
        let stats = Statistic()
        let significance = stats.tTest1Samp(corrSquared, popMean: 0)
        
        let mean = r2
        
        let sem = stats.sem(x: corrSquared, mean: mean)
        
        return (r2: r2, significance: significance, sem: sem, corrSquared: corrSquared)
    }
    
    /// calculates RSA by executing the corresponding function based on the data type
    /// - Parameters:
    ///   - modelRdm: the RDM from the selected model and one of it's layers
    ///   - brainRdm: the brain RDM used for calculating RSA
    ///   - dataType: data type of the brain data (fMRI or MEG)
    /// - Returns: the statistical values calculated in RSA
    func rsa(modelRdm: MfArray, brainRdm: MfArray, dataType: String) -> (r2: Float, significance: Float, sem: Float, corrSquared: MfArray) {
        //print("RSA for \(dataType)")
        if dataType == "fmri" {
            // fmri
            return rsaFmri(modelRdm: modelRdm, brainRdm: brainRdm)
        } else {
            // meg
            return rsaMeg(modelRdm: modelRdm, brainRdm: brainRdm)
        }
    }
    
    /// loops over the model RDMs and calculated RSA for every of them
    /// - Parameters:
    ///   - modelRDMs: dictionary of all modelRDMs; key is the layer's key
    ///   - roi: the brain RDM
    ///   - dataType: data type of the brain data (fMRI or MEG)
    ///   - finishedLayer: callback for updating the progress bar in UI
    /// - Returns: array of dictionaries containing the RSA results for every model layer RDM
    func evaluateRoi(modelRDMs: [String:MfArray], roi: MfArray, dataType: String, finishedLayer: ()->()) -> [[String:Any]] {
        var allLayerOutput = [[String:Any]]()
        
        for (layer, modelRdm) in modelRDMs {
            let rsaResult = rsa(modelRdm: modelRdm, brainRdm: roi, dataType: dataType)
            finishedLayer()
            
            let outputDict: [String:Any] = [
                "Layer": layer,
                "R2": rsaResult.r2,
                "Significance": rsaResult.significance,
                "SEM": rsaResult.sem,
                "R2_array": rsaResult.corrSquared
            ]
            allLayerOutput.append(outputDict)
        }
        
        return allLayerOutput
    }
    
    /// loops over all brain RDMs and model RDMs and calculates the RSA for every combination
    /// - Parameters:
    ///   - brainRdms: dictionary of brain RDMs, key is the ROI name
    ///   - modelName: the name of the ML model
    ///   - modelRdms: the RDMs for every selected layer for the model
    ///   - progressCallback: callback for updating progress bar in UI
    /// - Returns: an array of RSAOutput values
    func evaluate(brainRdms: [String:MfArray], modelName: String, modelRdms: [String:MfArray], progressCallback: (Double)->()) async -> [RSAOutput] {
        var allRoisOutput = [RSAOutput]()
        let totalCount = Double(brainRdms.count * modelRdms.count)
        var currentIndex = 0.0
        for (roiName, roi) in brainRdms {
            let dataType = roiName.contains("fmri") ? "fmri" : "meg"
            
            let allLayerOutput = evaluateRoi(modelRDMs: modelRdms, roi: roi, dataType: dataType, finishedLayer: {
                currentIndex += 1
                progressCallback(currentIndex / totalCount)
            })
            
            let index = Array(brainRdms.keys).firstIndex(of: roiName) ?? 0
            let scan_key = "(\(index + 1)) \(roiName)"
            
            for layerOutput in allLayerOutput {
                allRoisOutput.append(RSAOutput(
                    roi: scan_key,
                    layer: layerOutput["Layer"] as! String,
                    model: modelName,
                    r2: layerOutput["R2"] as! Float,
                    significance: layerOutput["Significance"] as! Float,
                    sem: layerOutput["SEM"] as! Float)
                )
            }
        }
        
        return allRoisOutput
    }
}
