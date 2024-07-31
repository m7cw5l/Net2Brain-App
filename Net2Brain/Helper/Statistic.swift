//
//  Statistic.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.12.23.
//

import Foundation
import Matft
import SwiftyStats

/// struct for statistical computations
struct Statistic {
    
    /// calculates the one-sample TTest
    /// - Parameters:
    ///   - array: the data the TTest should be performed for
    ///   - popMean: reference mean
    ///   - axis: the used axis in the data matrix (currently not used)
    ///   - alternative: the type of TTest (currently not used)
    /// - Returns: the p2 value for the performed TTest
    func tTest1Samp(_ array: MfArray, popMean: Float, axis: Int = 0, alternative: String = "two-sided") -> Float {
        let data: Array<Float> = array.toFlattenArray(datatype: Float.self, { $0 })
        let sample = SSExamine<Float, Float>.init(withArray: data, name: "data", characterSet: nil)
        
        do {
            let result = try SSHypothesisTesting.oneSampleTTest(sample: sample, mean: popMean, alpha: 0.95)
            
            return result.p2Value ?? 0.0
        } catch {
            print(error)
        }
        
        return 0.0
    }
    
    /// calculates the Standard Error of the Mean
    /// - Parameters:
    ///   - x: the data the SEM should be calculated for
    ///   - mean: the mean of the data
    /// - Returns: the SEM value
    func sem(x: MfArray, mean: Float) -> Float {
        /// Standard Error of Mean
        /// https://www.khanacademy.org/math/statistics-probability/summarizing-quantitative-data/variance-standard-deviation-population/a/calculating-standard-deviation-step-by-step; 21.11.2023 10:46
        /// https://en.wikipedia.org/wiki/Standard_error; 21.11.2023 11:20
        let n = x.count
        
        var sum: Float = 0.0
        for i in 0..<n {
            let value = x.item(index: i, type: Float.self)
            sum += pow(abs(value - mean), 2.0)
        }
        let sd = sqrt(sum / Float(n))
        return sd / sqrt(Float(n))
    }
    
    /*func sem(x: MfArray, mean: Float) -> Float {
        let data: Array<Float> = x.toFlattenArray(datatype: Float.self, { $0 })
        let sample = SSExamine<Float, Float>.init(withArray: data, name: "data", characterSet: nil)
        
        return sample.standardError ?? 0.0
    }*/
}
