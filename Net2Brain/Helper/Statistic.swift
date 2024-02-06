//
//  Statistic.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.12.23.
//

import Foundation
import Matft
import SwiftyStats


struct Statistic {
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
    
    /*func sem(x: MfArray, mean: Float) -> Float {
        /// Standard Error of Mean
        /// https://www.khanacademy.org/math/statistics-probability/summarizing-quantitative-data/variance-standard-deviation-population/a/calculating-standard-deviation-step-by-step; 21.11.2023 10:46
        /// https://en.wikipedia.org/wiki/Standard_error; 21.11.2023 11:20
        let n = x.count
        
        var sum = 0.0
        for i in 0..<n {
            let value = x.item(index: i, type: Float.self)
            sum += pow(Double(abs(value - mean)), 2)
        }
        let sd = sqrt(sum / Double(n))
        return Float(sd / sqrt(Double(n)))
    }*/
    
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
