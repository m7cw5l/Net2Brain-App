//
//  Net2BrainTests.swift
//  Net2BrainTests
//
//  Created by Marco Weßel on 18.09.23.
//

import XCTest
@testable import Net2Brain
import Matft

private extension RSAOutput {
    /// https://forums.swift.org/t/double-equatable-and-unit-tests-that-fails-because-they-are-almost-equal/12133/5 ; 06.02.2024 10:34
    static func almostEqual(lhs: RSAOutput, rhs: RSAOutput, accuracy: Float) {
        XCTAssertEqual(lhs.roi, rhs.roi)
        XCTAssertEqual(lhs.layer, rhs.layer)
        XCTAssertEqual(lhs.model, rhs.model)
        XCTAssertEqual(lhs.r2, rhs.r2, accuracy: accuracy)
        XCTAssertEqual(lhs.significance, rhs.significance, accuracy: accuracy)
        XCTAssertEqual(lhs.sem, rhs.sem, accuracy: accuracy)
    }
}

final class Net2BrainTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // Distance Tests
    func testEuclidian() async throws {
        let testMatrix = MfArray([1, 2, 3, 4, 5, 6, 7, 8], shape: [2, 2, 2])
        let correctDistanceMatrix = MfArray([[[1e-15, 2.828427],
                                              [2.828427, 1e-15]],
                                              [[1e-15, 2.828427],
                                              [2.828427, 1e-15]]], mftype: .Float)
        
        let result = await euclidean(x: testMatrix)
                        
        XCTAssertEqual(result, correctDistanceMatrix)
    }
    
    func testManhattan2D() async throws {
        let testMatrix = MfArray([1, 2, 3, 4, 5, 6, 7, 8], shape: [4, 2])
        let correctDistanceMatrix = MfArray([[    0.0,        4.0,        8.0,        12.0],
                                             [    4.0,        0.0,        4.0,        8.0],
                                             [    8.0,        4.0,        0.0,        4.0],
                                             [    12.0,        8.0,        4.0,        0.0]], mftype: .Float)
                
        let result = await manhattan(x: testMatrix)
                        
        XCTAssertEqual(result, correctDistanceMatrix)
    }
    
    func testManhattan3D() async throws {
        let testMatrix = MfArray([1, 2, 3, 4, 5, 6, 7, 8], shape: [2, 2, 2])
        let correctDistanceMatrix = MfArray([[[0.0, 4.0],
                                              [4.0, 0.0]],
                                             [[0.0, 4.0],
                                              [4.0, 0.0]]], mftype: .Float)
                
        let result = await manhattan(x: testMatrix)
                        
        XCTAssertEqual(result, correctDistanceMatrix)
    }
    
    func testCosine() async throws {
        let testMatrix = MfArray([1, 2, 3, 4, 5, 6, 7, 8], shape: [2, 2, 2])
        let correctDistanceMatrix = MfArray([[[5.9604645e-08, 0.016130209],
                                              [0.016130209, 2.9802322e-07]],
                                              [[1.1920929e-07, 0.00029027462],
                                              [0.00029027462, 5.9604645e-08]]], mftype: .Float)
        
        let result = await cosine(x: testMatrix)
                        
        XCTAssertEqual(result, correctDistanceMatrix)
    }
    
    func testCorrelation() async throws {
        let testMatrix = MfArray([1, 2, 3, 4, 5, 6, 7, 8], shape: [2, 2, 2])
        let correctDistanceMatrix = MfArray([[[5.9604645e-08, 5.9604645e-08],
                                              [5.9604645e-08, 5.9604645e-08]],
                                              [[5.9604645e-08, 5.9604645e-08],
                                              [5.9604645e-08, 5.9604645e-08]]], mftype: .Float)
        
        let result = await correlation(x: testMatrix)
                        
        XCTAssertEqual(result, correctDistanceMatrix)
    }
    
    // RSA Tests
    func testSquareform() throws {
        /// https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.distance.squareform.html ; 05.02.2024 13:46
        let testMatrix = MfArray([[0.0       , 2.23606798, 6.40312424, 7.34846923, 2.82842712],
                                  [2.23606798, 0.0       , 4.89897949, 6.40312424, 1.0       ],
                                  [6.40312424, 4.89897949, 0.0       , 5.38516481, 4.58257569],
                                  [7.34846923, 6.40312424, 5.38516481, 0.0       , 5.47722558],
                                  [2.82842712, 1.0       , 4.58257569, 5.47722558, 0.0       ]], mftype: .Float)
        let correctSquareform = MfArray([2.23606798, 6.40312424, 7.34846923, 2.82842712, 4.89897949,
                                         6.40312424, 1.0       , 5.38516481, 4.58257569, 5.47722558], mftype: .Float)
        
        let rsa = RSA()
        let result = rsa.sq(x: testMatrix)
        
        XCTAssertEqual(result, correctSquareform)
    }
    
    func testSpearman() throws {
        let testMatrix1 = MfArray([35, 20, 49, 44, 30], mftype: .Float)
        let testMatrix2 = MfArray([24, 35, 39, 48, 45], mftype: .Float)
        
        let correctSpearman: Float = 0.3
        
        let rsa = RSA()
        XCTAssertEqual(rsa.spearman(x: testMatrix1, y: testMatrix2), correctSpearman)
    }
    
    func testSpearman2() throws {
        /// https://statistics.laerd.com/statistical-guides/spearmans-rank-order-correlation-statistical-guide-2.php ; 05.02.2024 14:50
        let testMatrix1 = MfArray([56, 75, 45, 71, 62, 64, 58, 80, 76, 61], mftype: .Float)
        let testMatrix2 = MfArray([66, 70, 40, 60, 65, 56, 59, 77, 67, 63], mftype: .Float)
        
        let correctSpearman: Float = 0.67
        
        let rsa = RSA()
        
        XCTAssertEqual(rsa.spearman(x: testMatrix1, y: testMatrix2), correctSpearman, accuracy: 0.01)
    }
    
    func testtTest1Samp() throws {
        let testData = MfArray([0.09648315394551149, 0.04717157872621917, 0.023405011109169278, 0.04310264484174288, 0.06844311996580657, 0.02584999619954568, 0.014340339762539431, 0.02782465629072108, 0.02411025644626679, 0.04158300858636453, -0.000577226208873464, 0.031818164669676886, 0.06784223989797548, 0.04190442607174994, 0.04235470238605298], mftype: .Float)
        let squareTestData = Matft.math.square(testData)
        
        let correctValue: Float = 0.004615479
        
        let stats = Statistic()
        let p = stats.tTest1Samp(squareTestData, popMean: 0)
        
        XCTAssertEqual(p, correctValue, accuracy: 0.0001)
    }
    
    // Test RSA
    struct LayerFile: Decodable {
        var data: [Float]
        var shape: [Int]
    }
    
    func loadLayers(_ casePath: String, _ layers: [String]) -> [String:MfArray] {
        //let bundle = Bundle(for: Net2BrainTests.self)
        /*guard let resourcePath = bundle.resourcePath else {
            return [:]
        }*/
        
        var output = [String:MfArray]()
        for layer in layers {
            //let layerArray = loadLayerFile(path: "\(resourcePath)/rsa_test_data/\(casePath)/\(layer).gzip")
            let layerArray = loadLayerFile(layer)
            output[layer] = layerArray
        }
        
        return output
    }
    
    func loadLayerFile(_ layer: String) -> MfArray {
        let bundle = Bundle(for: Net2BrainTests.self)
        guard let path = bundle.path(forResource: layer, ofType: "gzip") else {
            return MfArray([-1])
        }
        
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
            let fileData = try decoder.decode(LayerFile.self, from: decompressedData)
            return MfArray(fileData.data, mftype: .Float, shape: fileData.shape)
        } catch {
            print("JSON serialization failed")
        }
        
        return MfArray([-1])
    }
    
    func loadResultsFile(_ casePath: String) -> [RSAOutput] {
        let bundle = Bundle(for: Net2BrainTests.self)
        guard let path = bundle.path(forResource: "results_\(casePath)", ofType: "gzip") else {
            return []
        }
        
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
        //print(String(decoding: decompressedData, as: UTF8.self))
        let decoder = JSONDecoder()
        do {
            let fileData = try decoder.decode([RSAOutput].self, from: decompressedData)
            return fileData
        } catch {
            print("JSON serialization failed")
        }
        
        return []
    }
    
    func testRSA() async throws {
        /// case1: ResNet18
        /// case2: RN50
        let testCases = [
            (name: "case1", layerNames: ["layer3.1.conv2", "layer4.1.bn2"], model: "ResNet18"),
            (name: "case2", layerNames: ["visual.layer4"], model: "RN50")
        ]
        for testCase in testCases {
            let distanceMatrices = loadLayers(testCase.name, testCase.layerNames)
            
            let rsa = RSA()
            let brainRdms = await rsa.loadBrainRdms(dataset: "78images", images: (1...78).map { String(format: "78images_%05d", $0) }, progressCallback: { progress in
            })
            
            let rsaOutputs = await rsa.evaluate(brainRdms: brainRdms, modelName: testCase.model, modelRdms: distanceMatrices, progressCallback: { progress in
            })
            let filteredRsaOutputs = rsaOutputs.filter({ output in
                output.roi.contains("fmri_IT_RDMs") || output.roi.contains("fmri_EVC_RDMs")
            }).map({ output in
                var output = output
                output.roi = String(output.roi.dropFirst(4))
                
                return output
            }).sorted(by: {
                ($0.roi, $0.layer) > ($1.roi, $1.layer)
            })
            
            let correctResults = loadResultsFile(testCase.name).sorted(by: {
                ($0.roi, $0.layer) > ($1.roi, $1.layer)
            })
                        
            for (result, correct) in zip(filteredRsaOutputs, correctResults) {
                RSAOutput.almostEqual(lhs: result, rhs: correct, accuracy: 0.00005)
            }
        }
    }

    /*func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/

}
