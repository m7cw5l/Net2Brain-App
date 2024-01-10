//
//  Net2BrainTests.swift
//  Net2BrainTests
//
//  Created by Marco Weßel on 18.09.23.
//

import XCTest
@testable import Net2Brain
import Matft

final class Net2BrainTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
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
    
    func testSpearman() throws {
        let testMatrix1 = MfArray([35, 20, 49, 44, 30], mftype: .Float)
        let testMatrix2 = MfArray([24, 35, 39, 48, 45], mftype: .Float)
        
        let correctSpearman: Float = 0.3
        
        let rsa = RSA()
        XCTAssertEqual(rsa.spearman(x: testMatrix1, y: testMatrix2), correctSpearman)
    }

    func testExample() throws {
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
    }

}
