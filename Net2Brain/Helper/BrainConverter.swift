//
//  3DConverter.swift
//  Net2Brain
//
//  Created by Marco Weßel on 18.10.23.
//

import Foundation
import SceneKit
import Gzip /// https://github.com/1024jp/GzipSwift; 18.10.23 10:41
import SwiftUI

///https://www.hackingwithswift.com/example-code/uicolor/how-to-read-the-red-green-blue-and-alpha-color-components-from-a-uicolor; 19.10.23 11:40
extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

struct Vector: Codable {
    let x: Float
    let y: Float
    let z: Float
}

func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}

struct BrainConverter {
    var environment: EnvironmentValues
    
    /// heatmap from matplotlib/nilearn ("cold_hot")
    let heatmap = [
        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.28409019, green: 1.0, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0, green: 0.71212101, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0, green: 0.23484906, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0, green: 0.0, blue: 0.75755961, alpha: 1.0),
        UIColor(red: 0.0, green: 0.0, blue: 0.2802532, alpha: 1.0),
        UIColor(red: 0.2802532, green: 0.0, blue: 0.0, alpha: 1.0),
        UIColor(red: 0.75755961, green: 0.0, blue: 0.0, alpha: 1.0),
        UIColor(red: 1.0, green: 0.23484906, blue: 0.0, alpha: 1.0),
        UIColor(red: 1.0, green: 0.71212101, blue: 0.0, alpha: 1.0),
        UIColor(red: 1.0, green: 1.0, blue: 0.28409019, alpha: 1.0),
        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    ]
    let threshold = 1e-14
    
    @Binding var hemisphere: String
    @Binding var roi: ROI
    @Binding var image: String
    
    func getColorExtremes() -> (min: Int, max: Int) {
        if image != "" {
            guard let resourcePath = Bundle.main.resourcePath else {
                return (0, 0)
            }
            
            let colorMapFilePath = "\(resourcePath)/roi_\(hemisphere)_\(roi.rawValue)_color_map_\(image).gzip"
            
            let colorMap = readJSONFileColors(colorMapFilePath)
            
            let min = colorMap.min() ?? 0.0
            let max = colorMap.max() ?? 0.0
            
            return (Int(min), Int(max))
        } else {
            return (0, 0)
        }
    }
    
    func createGeometry() async -> SCNGeometry {
        guard let resourcePath = Bundle.main.resourcePath else {
            return SCNGeometry()
        }
                
        let verticesFilePath = "\(resourcePath)/brain_vertices_\(hemisphere).gzip"
        let normalsFilePath = "\(resourcePath)/brain_normals_\(hemisphere).gzip"
        let facesFilePath = "\(resourcePath)/brain_faces_\(hemisphere).gzip"

        let vertices = readJSONFileVectors(verticesFilePath)
        let normals = readJSONFileVectors(normalsFilePath)
        let faces = readJSONFileIndices(facesFilePath)
        
        let surfaceFilePath = "\(resourcePath)/brain_surface_\(hemisphere).gzip"
        var surface = readJSONFileSurface(surfaceFilePath)
        
        var colorMapFilePath = "\(resourcePath)/roi_\(hemisphere)_\(roi.rawValue)_color_map.gzip"
        if image != "" {
            colorMapFilePath = "\(resourcePath)/roi_\(hemisphere)_\(roi.rawValue)_color_map_\(image).gzip"
        }
        let colorMap = readJSONFileColors(colorMapFilePath)
        
        if image == "" {
            // no heatmap; only one color
            //let pinkVector = SCNVector3(223.0 / 255.0, 0.0, 211.0 / 255.0)
            let accentColor = Color(.accent).resolve(in: environment)
            let accentColorVector = SCNVector3(accentColor.red, accentColor.green, accentColor.blue)
            
            for (index, color) in colorMap.enumerated() {
                if color != 0.0 {
                    //surface[index] = pinkVector
                    surface[index] = accentColorVector
                }
            }
        } else {
            // add heatmap
            let min = colorMap.min() ?? 0.0
            let max = colorMap.max() ?? 0.0
            
            let difference = abs(max - min)
            
            let stepSize = difference / Float(heatmap.count)
            
            for (index, color) in colorMap.enumerated() {
                if color != 0.0 {
                    var steps = Int(floor((color - min) / stepSize))
                    steps = (steps < 0) ? 0 : steps
                    steps = (steps > heatmap.count - 1) ? heatmap.count - 1 : steps
                    let uicolorValues = heatmap[steps].rgba
                    
                    let colorVector = SCNVector3(uicolorValues.0, uicolorValues.1, uicolorValues.2)
                    surface[index] = colorVector
                    //print(steps)
                }
            }
        }
        
        /// https://github.com/aheze/CustomSCNGeometry; 18.10.23 08:27
        let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<SCNVector3>.size)
        let vertexSource = SCNGeometrySource(data: vertexData, semantic: SCNGeometrySource.Semantic.vertex, vectorCount: vertices.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)

        let normalData = Data(bytes: normals, count: MemoryLayout<SCNVector3>.size * normals.count)
        let normalSource = SCNGeometrySource(data: normalData, semantic: SCNGeometrySource.Semantic.normal, vectorCount: normals.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
        
        /// https://stackoverflow.com/a/32831830; 18.10.23 08:48
        let colorData = Data(bytes: surface, count: MemoryLayout<SCNVector3>.size * surface.count)
        let colorSource = SCNGeometrySource(data: colorData, semantic: SCNGeometrySource.Semantic.color, vectorCount: surface.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
        
        let indexData = Data(bytes: faces, count: MemoryLayout<Int32>.size * faces.count)
        let indexElement = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.triangles, primitiveCount: faces.count / 3, bytesPerIndex: MemoryLayout<CInt>.size)
        
        let geometry = SCNGeometry(sources: [vertexSource, normalSource, colorSource], elements: [indexElement])

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.lightingModel = .physicallyBased
        geometry.materials = [material]
        
        return geometry
    }
    
    func createScene() async -> SCNScene {
        let geometry = await createGeometry()
        
        // create scene/
        let scene = SCNScene()
        DispatchQueue.main.async {
            // add the node
            let brainNode = SCNNode(geometry: geometry)
            //brainNode.scale = SCNVector3(0.000001, 0.000001, 0.000001)
            brainNode.scale = SCNVector3(0.01, 0.01, 0.01)
            
            /// https://developer.apple.com/documentation/scenekit/scnnode/1407980-eulerangles; 18.10.23 11:11
            if hemisphere == "left" {
                brainNode.eulerAngles = SCNVector3(deg2rad(-90.0), deg2rad(90.0), deg2rad(0.0))
            } else {
                brainNode.eulerAngles = SCNVector3(deg2rad(-90.0), deg2rad(-90.0), deg2rad(0.0))
            }
            scene.rootNode.addChildNode(brainNode)
            
            let camera = SCNCamera()
            camera.zNear = 0.1
            camera.zFar = 10
            
            let cameraNode = SCNNode()
            cameraNode.name = "camera"
            cameraNode.camera = camera
            
            if image != "" {
                cameraNode.position = SCNVector3Make(0.0, 0.0, 2.0)
            } else {
                cameraNode.position = SCNVector3Make(0.0, 0.0, 3.0)
            }
            
            scene.rootNode.addChildNode(cameraNode)
        }
        return scene
    }
}

func readJSONFileVectors(_ path: String) -> [SCNVector3] {
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
        let vectors = try decoder.decode([Vector].self, from: decompressedData)
        let scnVectors  = vectors.map { SCNVector3(x: $0.x, y: $0.y, z: $0.z) }
        
        return scnVectors
        
        //print("FINISHED DATA")
    } catch {
        print("JSON serialization failed")
    }
    
    return []
}

func readJSONFileIndices(_ path: String) -> [Int32] {
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
        let intData = try decoder.decode([Int].self, from: decompressedData)
        let indices  = intData.map { Int32($0) }
        
        return indices
        
        //print("FINISHED DATA")
    } catch {
        print("JSON serialization failed")
    }
    
    return []
}

func readJSONFileSurface(_ path: String) -> [SCNVector3] {
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
        let rawColor = try decoder.decode([Float].self, from: decompressedData)
        
        //let colorVectors = rawColor.map { SCNVector3($0, $0, $0) }
        let colorVectors = rawColor.map { SCNVector3(abs(1.0 - $0), abs(1.0 - $0), abs(1.0 - $0)) }
        
        return colorVectors
    } catch {
        print("JSON serialization failed")
    }
    
    return []
}

func readJSONFileColors(_ path: String) -> [Float] {
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
        return try decoder.decode([Float].self, from: decompressedData)
    } catch {
        print("JSON serialization failed")
    }
    
    return []
}
