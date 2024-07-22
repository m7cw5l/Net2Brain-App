//
//  RSABrainView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 21.03.24.
//

import SwiftUI
import SceneKit

struct RSABrainView: View {    
    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @Environment(\.self) var environment
    @Environment(\.colorScheme) var colorScheme
    @State private var backgroundColor: Color = .white
    
    @State var selectedLayer: N2BMLLayer = N2BMLLayer(name: "", layerDescription: "", coremlKey: "")
    @State private var selectedHemisphere = "left"
    
    var selectedBrain: [String] {[
        selectedLayer.coremlKey,
        selectedHemisphere
    ]}
    
    @State private var loadingBrain = true
    
    @State private var sceneViewSize = CGSize.zero
    
    @State private var scene = SCNScene()
    var cameraNode: SCNNode? {
        scene.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    @State var explanation = Explanation(title: "explanation.general.alert.title", description: "explanation.visualization.roi", show: false)
    
    var body: some View {
        VStack {
            // https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-two-views-the-same-width-or-height#; 16.10.23 16:05
            HStack {
                VStack {
                    VStack {
                        Text("pipeline.rsa.chart.layer.select.title").font(.headline)
                        Picker("pipeline.rsa.chart.layer.select.title", selection: $selectedLayer) {
                            ForEach(pipelineParameters.mlModelLayers, id: \.self) {
                                Text($0.name).tag($0)
                            }
                        }//.pickerStyle(.segmented)
                    }
                }.padding(.vertical)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
                    .clipShape(.rect(cornerRadius: 16))
                
                VStack {
                    Text("hemisphere.title").font(.headline)
                    Picker("hemisphere.title", selection: $selectedHemisphere) {
                        Text("hemisphere.left").tag("left")
                        Text("hemisphere.right").tag("right")
                    }.pickerStyle(.segmented)
                        .fixedSize()
                }.padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
                    .clipShape(.rect(cornerRadius: 16))
            }.fixedSize(horizontal: false, vertical: true)
                        
            GeometryReader { geo in
                ZStack {
                    SceneView(
                        scene: scene,
                        pointOfView: cameraNode,
                        options: [.allowsCameraControl, .autoenablesDefaultLighting, .temporalAntialiasingEnabled],
                        delegate: nil
                    )//.scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .zIndex(1.0)
                    if loadingBrain {
                        VStack {
                            ProgressView()
                            Spacer().frame(height: 8.0)
                            Text("3d.model.generation.running").font(.callout)
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .background()
                            .zIndex(2.0)
                            .allowsHitTesting(false)
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background()
                    .clipShape(.rect(cornerRadius: 16))
                    .onChange(of: geo.size) {
                        sceneViewSize = geo.size
                        //print(sceneViewSize)
                    }
            }
            
            Button("explanation.general.button.title", systemImage: "questionmark.circle", action: {
                explanation.show.toggle()
            }).padding(.top)
        }
        .padding()
        .background(Color(uiColor: UIColor.secondarySystemBackground))
        .navigationTitle("view.roi.visualize.title")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            scene.background.contents = (colorScheme == .dark ? UIColor.black : UIColor.white)
        }
        .onChange(of: selectedBrain, initial: true) {
            Task {
                scene = SCNScene()
                scene.background.contents = (colorScheme == .dark ? UIColor.black : UIColor.white)
                withAnimation {
                    loadingBrain = true
                }
                if sceneViewSize != .zero {
                    let _ = pipelineData.allRoisOutput.filter {
                        $0.layer == selectedLayer.coremlKey
                    }.first
                    
                    let brainConverter = BrainConverter(environment: environment, visualizationType: .rsa, hemisphere: $selectedHemisphere, roi: .constant(ROI.all), image: .constant(""), brainVisualizationValues: getVisualizationValues(), sceneViewSize: $sceneViewSize)
                    scene = await brainConverter.createScene()
                    scene.background.contents = (colorScheme == .dark ? UIColor.black : UIColor.white)
                    
                    withAnimation() {
                        loadingBrain = false
                    }
                }
            }
        }
        .sheet(isPresented: $explanation.show) {
            /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
            ExplanationSheet(sheetTitle: $explanation.title, sheetDescription: $explanation.description)
        }
    }
    
    func getVisualizationValues() -> BrainVisualizationValues {
        if pipelineParameters.dataset.name == "78images" {
            
        } else {
            
        }
        
        return BrainVisualizationValues(visual: 0, body: 1, face: 2, place: 3, word: 4, anatomical: 5)
    }
}

#Preview {
    RSABrainView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData())
}
