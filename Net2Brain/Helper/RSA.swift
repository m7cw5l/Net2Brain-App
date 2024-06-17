//
//  RSA.swift
//  Net2Brain
//
//  Created by Marco Weßel on 21.11.23.
//

import Foundation
import Matft

struct RSA {
    struct RdmFile: Decodable {
        var data: [Float]
        var shape: [Int]
    }
    
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
    
    func loadBrainRdms(dataset: String, images: [String], progressCallback: (Double)->()) async -> [String:MfArray] {
        let imageIndices = images.map {
            (Int($0.suffix(5)) ?? 0) - 1
        }
                
        let brainRdms92images = ["fmri_EVC_RDMs", "fmri_IT_RDMs", "meg_MEG_RDMs_early", "meg_MEG_RDMs_late"]
        let brainRdms78images = ["fmri_EVC_RDMs", "fmri_IT_RDMs", "fmri_T2_EVC_RDMs", "fmri_T2_IT_RDMs", "MEG_RDMs_early", "MEG_RDMs_late", "MEG_T2_RDMs_early", "MEG_T2_RDMs_late"]
        
        guard let resourcePath = Bundle.main.resourcePath else {
            return [:]
        }
        
        let rdmNames = (dataset == "78images" ? brainRdms78images : brainRdms92images)
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
    
    func shrinkBrainRdm(_ brainRdm: MfArray, imageIndices: [Int]) -> MfArray {
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
            return output
        }
        return MfArray([-1])
    }
    
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
    
    func rankArray(_ array: MfArray) -> MfArray {
        ///https://stackoverflow.com/a/5284703 ; 04.12.2023 16:35
        let temp = array.argsort(order: .Descending)
        let ranks = Matft.nums_like(0, mfarray: temp)
        ranks[temp] = Matft.arange(start: 0, to: array.count, by: 1)
        return ranks
    }
    
    func spearman(x: MfArray, y: MfArray) -> Float {
        /// https://www.simplilearn.com/tutorials/statistics-tutorial/spearmans-rank-correlation ; 21.11.2023 11:27
                
        // Step 1: add ranks to the input arrays
        let xRanks = rankArray(x)
        let yRanks = rankArray(y)
        //print("STEP 1 DONE")
        
        // Step 2: calculate the difference between the ranks
        let diffs = Matft.math.abs(xRanks - yRanks)
        //print("STEP 2 DONE")
        
        // Step 3: square the differences
        let diffSquare = Matft.math.square(diffs)
        //print("STEP 3 DONE")
        
        // Step 4:
        let n = x.shape.first ?? 0
        let differenceSum = diffSquare.sum().item(index: 0, type: Float.self)
        let nenner = n * (n * n - 1)
        let result = 1 - ((Float(6) * differenceSum) / Float(nenner))
        //print("STEP 4 DONE")
        
        return result
    }
    
    func distance(modelRdm: MfArray, rdms: MfArray) -> MfArray {
        //let modelRdmVector = modelRdm.flatten()
        let modelRdmVector = sq(x: modelRdm) // TODO: Test Squareform
        //print(modelRdmVector.shape)
        var corrList = [Float]()
        for rdm in rdms {
            //let rdmVector = rdm.flatten()
            let rdmVector = sq(x: rdm) // TODO: Test Squareform
            
            //let spearmanResult = spearman(x: modelRdm, y: rdm)
            let spearmanResult = spearman(x: modelRdmVector, y: rdmVector)
            corrList.append(spearmanResult)
        }
        
        return MfArray(corrList)
    }
    
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
        
        print("FINISHED ROI")
        return allLayerOutput
    }
    
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
