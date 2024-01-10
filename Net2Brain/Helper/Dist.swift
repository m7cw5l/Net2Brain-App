//
//  Dist.swift
//  Net2Brain
//
//  Created by Marco Weßel on 07.11.23.
//

import Matft

/// Performs batchwise matrix-matrix multiplication. Based on `torch.baddbmm`.
/// Formula: `out_i = `
/// - Parameters:
///   - input:
///   - batch1: 2D or 3D MfArray
///   - batch2: 2D or 3D MfArray
///   - beta:
///   - alpha: 
/// - Returns: 2D or 3D MfArray
func baddbmm(input: MfArray, batch1: MfArray, batch2: MfArray, beta: Int = 1, alpha: Int = 1) async -> MfArray {
    let batchSize = input.shape.first ?? 0
        
    var outputArray = [MfArray]()
    
    for i in 0..<batchSize {
        let out_i = beta * input[i] + alpha * Matft.matmul(batch1[i], batch2[i])
        outputArray.append(out_i)
    }
    
    let output = Matft.concatenate(outputArray).reshape(batch1.shape)
    
    return output
}

func addmm(input: MfArray, batch1: MfArray, batch2: MfArray, beta: Int = 1, alpha: Int = 1) async -> MfArray {
    let out = beta * input + alpha * Matft.matmul(batch1, batch2)
    
    return out
}


func euclidean(x: MfArray, y: MfArray? = nil) async -> MfArray? {
    var y = y
    
    let xNorm = Matft.math.square(x).sum(axis: x.ndim - 1, keepDims: true)
        
    var yNorm: MfArray? = nil
    
    if let y = y {
        // y is defined
        yNorm = Matft.math.square(y).sum(axis: y.ndim - 1, keepDims: true)
    } else {
        y = x
        yNorm = xNorm
    }
        
    if let y = y {
        if let yNorm = yNorm {
            if x.ndim == 3 {
                print("3 Dimensions")
                let result = await baddbmm(input: xNorm, batch1: x, batch2: y.swapaxes(axis1: -2, axis2: -1), alpha: -2)
                return Matft.math.sqrt(Matft.clip(Matft.add(result, yNorm.swapaxes(axis1: -2, axis2: -1)), min: 1e-30))
            } else {
                print("not 3 Dimensions")
                let result = await addmm(input: xNorm, batch1: x, batch2: y.swapaxes(axis1: -2, axis2: -1), alpha: -2)
                return Matft.math.sqrt(Matft.clip(Matft.add(result, yNorm.swapaxes(axis1: -2, axis2: -1)), min: 1e-30))
            }
        }
    }
    
    return nil
}


func manhattanOld(x: MfArray, y: MfArray? = nil) async -> MfArray? {
    var y = y
    if y == nil {
        y = x
    }
    
    print(x.shape)
    
    if let y = y {
        let batchSize = x.shape.first ?? 0
        
        print(batchSize)
        
        var outputArray = [MfArray]()
        
        for i in 0..<batchSize {
            let vectorCount = x[i].shape.first ?? 0
            print(vectorCount)
            var vectorOutput = [MfArray]()
            for j in 0..<vectorCount {
                for k in 0..<vectorCount {
                    let value = Matft.math.abs(x[i][j] - y[i][k]).sum()
                    vectorOutput.append(value)
                }
            }
            
            outputArray.append(Matft.concatenate(vectorOutput))
        }
        
        print(outputArray)
        let output = Matft.concatenate(outputArray).reshape(x.shape)
                
        return output
    }
    return nil
}

func manhattan(x: MfArray, y: MfArray? = nil) async -> MfArray? {
    var y = y
    if y == nil {
        y = x
    }
        
    if let y = y {
        let batchSize = x.shape.first ?? 0
        
        var outputArray = [MfArray]()
        
        if x.ndim == 3 {
            for i in 0..<batchSize {
                let vectorCount = x[i].shape.first ?? 0
                var vectorOutput = [MfArray]()
                for j in 0..<vectorCount {
                    for k in 0..<vectorCount {
                        let value = Matft.math.abs(x[i][j] - y[i][k]).sum()
                        vectorOutput.append(value)
                    }
                }
                outputArray.append(Matft.concatenate(vectorOutput))
            }
            return Matft.concatenate(outputArray).reshape(x.shape)
        } else {
            for i in 0..<batchSize {
                var batchOutput = [MfArray]()
                for j in 0..<batchSize {
                    let value = Matft.math.abs(x[i] - y[j]).sum()
                    batchOutput.append(value)
                }
                outputArray.append(Matft.concatenate(batchOutput))
            }
            return Matft.concatenate(outputArray).reshape([batchSize, batchSize])
        }
    }
    
    return nil
}


func cosine(x: MfArray, y: MfArray? = nil) async -> MfArray? {
    let xNorm = x / Matft.linalg.normlp_vec(x, ord: 2, axis: -1, keepDims: true)
    
    var yNorm: MfArray? = nil
    
    if let y = y {
        yNorm = y / Matft.linalg.normlp_vec(y, ord: 2, axis: -1, keepDims: true)
    } else {
        yNorm = xNorm
    }
    
    if let yNorm = yNorm {
        return 1 - Matft.matmul(xNorm, yNorm.swapaxes(axis1: -2, axis2: -1))
    }
    
    return nil
}


/// Computes the pairwise correlation distance between all vectors in `x`.
/// Formula: `correlation(x, y) = 1 - (x - x.mean()) . (y - y.mean()) / (||x - x.mean()||_2 * ||y - y.mean()||_2)`
/// - Parameters:
///   - x: 2D or 3D MfArray
///   - y: 2D or 3D MfArray, optional
/// - Returns: 2D or 3D MfArray
func correlation(x: MfArray, y: MfArray? = nil) async -> MfArray? {
    var x = x
    var yArray = y
    
    x = x - Matft.stats.mean(x, axis: -1, keepDims: true)
    x = x / Matft.linalg.normlp_vec(x, ord: 2, axis: -1, keepDims: true)
    
    if let y = y {
        yArray = y - Matft.stats.mean(y, axis: -1, keepDims: true)
        yArray = y / Matft.linalg.normlp_vec(y, ord: 2, axis: -1, keepDims: true)
    } else {
        yArray = x
    }
    
    if let y = yArray {
        return 1 - Matft.matmul(x, y.swapaxes(axis1: -2, axis2: -1))
    }
    return nil
}
