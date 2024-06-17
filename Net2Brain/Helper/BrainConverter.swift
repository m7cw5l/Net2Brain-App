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

enum BrainVisualizationType {
    case roi, fmri, rsa
}

struct Vector: Codable {
    let x: Float
    let y: Float
    let z: Float
}

func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}

enum CameraStyle {
    case perspective, orthographic
}

struct BrainVisualizationValues {
    let visual: Float
    let body: Float
    let face: Float
    let place: Float
    let word: Float
    let anatomical: Float
    
    func getMin() -> Float {
        return [visual, body, face, place, word, anatomical].min() ?? 0.0
    }
    
    func getMax() -> Float {
        return [visual, body, face, place, word, anatomical].max() ?? 0.0
    }
}

struct BrainConverter {
    var environment: EnvironmentValues
    
    let heatmap = Heatmaps().coldHotUI
    let threshold = 1e-14
    
    @State var visualizationType: BrainVisualizationType
    @Binding var hemisphere: String
    @Binding var roi: ROI
    @Binding var image: String
    //@State var rsaOutput: RSAOutput? = nil
    @State var brainVisualizationValues: BrainVisualizationValues? = nil
    
    @Binding var sceneViewSize: CGSize
    
    /// https://stackoverflow.com/a/51679667 ; 09.04.2024 11:31
    func calculateColor(orgColor: UIColor, overlayColor: UIColor) -> UIColor {
        // Helper function to clamp values to range (0.0 ... 1.0)
        func clampValue(_ v: CGFloat) -> CGFloat {
            guard v > 0 else { return  0 }
            guard v < 1 else { return  1 }
            return v
        }

        var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))

        orgColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        overlayColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        // Make sure the input colors are well behaved
        // Components should be in the range (0.0 ... 1.0)
        r1 = clampValue(r1)
        g1 = clampValue(g1)
        b1 = clampValue(b1)

        r2 = clampValue(r2)
        g2 = clampValue(g2)
        b2 = clampValue(b2)
        a2 = clampValue(a2)

        let color = UIColor(  red: r1 * (1 - a2) + r2 * a2,
                            green: g1 * (1 - a2) + g2 * a2,
                             blue: b1 * (1 - a2) + b2 * a2,
                            alpha: 1)

        return color
    }
    
    func getSurfaceWithColorMap() -> [SCNVector3] {
        guard let resourcePath = Bundle.main.resourcePath else {
            return []
        }
        
        let surfaceFilePath = "\(resourcePath)/brain_surface_\(hemisphere).gzip"
        var surface = readJSONFileSurface(surfaceFilePath)
        
        switch visualizationType {
        case .roi:
            let colorMapFilePath = "\(resourcePath)/roi_\(hemisphere)_\(roi.rawValue)_color_map.gzip"
            let colorMap = readJSONFileColors(colorMapFilePath)
            
            // no heatmap; only one color
            let accentColor = Color(.accent).resolve(in: environment)
            let accentColorVector = SCNVector3(accentColor.red, accentColor.green, accentColor.blue)
            
            for (index, color) in colorMap.enumerated() {
                if color != 0.0 {
                    surface[index] = accentColorVector
                }
            }
        case .fmri:
            let colorMapFilePath = "\(resourcePath)/roi_\(hemisphere)_\(roi.rawValue)_color_map_\(image).gzip"
            let colorMap = readJSONFileColors(colorMapFilePath)
            
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
                }
            }
        case .rsa:
            let minValue = brainVisualizationValues?.getMin() ?? 0.0
            let maxValue = brainVisualizationValues?.getMax() ?? 0.0
            let difference = abs(maxValue - minValue)
                                    
            let values = [brainVisualizationValues?.anatomical, brainVisualizationValues?.visual, brainVisualizationValues?.body, brainVisualizationValues?.face, brainVisualizationValues?.place, brainVisualizationValues?.word]
            let colorMaps = [ROI.anatomical, ROI.visual, ROI.body, ROI.face, ROI.place, ROI.word].map { roi in
                let colorMapFilePath = "\(resourcePath)/roi_\(hemisphere)_\(roi.rawValue)_color_map.gzip"
                return readJSONFileColors(colorMapFilePath)
            }
            
            for (value, colorMap) in zip(values, colorMaps) {
                let percentage = Double((value ?? 0.0) / difference)
                let roiColor = Color(uiColor: calculateColor(orgColor: UIColor.white, overlayColor: UIColor(Color(.accent).opacity(percentage)))).resolve(in: environment)
                let roiColorVector = SCNVector3(roiColor.red, roiColor.green, roiColor.blue)
                
                for (index, color) in colorMap.enumerated() {
                    if color != 0.0 {
                        surface[index] = roiColorVector
                    }
                }
            }
        }
        
        return surface
    }
    
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
        
        let surface = getSurfaceWithColorMap()
        
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
        
        // create scene
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
            
            let cameraStyle = CameraStyle.perspective
            let camera = SCNCamera()
            
            if cameraStyle == .orthographic {
                let viewAspectRatio = sceneViewSize.height / sceneViewSize.width
                
                camera.projectionDirection = .vertical
                camera.usesOrthographicProjection = true
                camera.orthographicScale = 1.2 * viewAspectRatio
                
                let cameraNode = SCNNode()
                cameraNode.name = "camera"
                cameraNode.camera = camera
                
                cameraNode.position = SCNVector3Make(0.0, 0.0, 5.0)
                
                scene.rootNode.addChildNode(cameraNode)
            } else {
                camera.zNear = 0.1
                camera.zFar = 10
                camera.projectionDirection = .vertical
                camera.fieldOfView = 50
                
                let cameraNode = SCNNode()
                cameraNode.name = "camera"
                cameraNode.camera = camera
                
                let viewAspectRatio = Float(sceneViewSize.height / sceneViewSize.width)
                
                cameraNode.position = SCNVector3Make(0.0, 0.0, (2.5 * viewAspectRatio))
                
                scene.rootNode.addChildNode(cameraNode)
            }
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
