//
//  VisualizeRoiView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI
import SceneKit

struct VisualizeRoiView: View {
    @Environment(\.self) var environment
    @Environment(\.colorScheme) var colorScheme
    @State private var backgroundColor: Color = .white
    
    @State private var selectedRoi: ROI = .all
    @State private var selectedHemisphere = "left"
    
    var selectedBrain: [String] {[
        selectedRoi.rawValue,
        selectedHemisphere
    ]}
    
    @State private var loadingBrain = true
        
    @State private var scene = SCNScene()
    var cameraNode: SCNNode? {
        scene.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    @State var explanation = Explanation(title: "explanation.general.alert.title", description: "explanation.visualization.roi", show: false)
        
    var body: some View {
        NavigationStack {
            VStack {
                // https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-two-views-the-same-width-or-height#; 16.10.23 16:05
                HStack {
                    VStack {
                        Text("roi.title.long").font(.headline)
                        Picker("roi.title", selection: $selectedRoi) {
                            Label("roi.all", systemImage: "brain").tag(ROI.all)
                            Label("roi.visual", systemImage: "eyes").tag(ROI.visual)
                            Label("roi.body", systemImage: "figure.stand").tag(ROI.body)
                            Label("roi.face", systemImage: "face.smiling").tag(ROI.face)
                            Label("roi.place", systemImage: "map").tag(ROI.place)
                            Label("roi.word", systemImage: "text.bubble").tag(ROI.word)
                            Label("roi.anatomical", systemImage: "figure.run").tag(ROI.anatomical)
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
                    //.fixedSize()
                }.fixedSize(horizontal: false, vertical: true)
                //.padding(.bottom)
                
                ZStack {
                    SceneView(
                        scene: scene,
                        pointOfView: cameraNode,
                        options: [.allowsCameraControl, .autoenablesDefaultLighting],
                        delegate: nil
                    ).scaledToFill()
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
                
                Button("explanation.general.button.title", systemImage: "questionmark.circle", action: {
                    explanation.show.toggle()
                }).padding([.top])
            }
            .padding()
            .background(Color(uiColor: UIColor.secondarySystemBackground))
                .navigationTitle("view.roi.visualize.title")
                .navigationBarTitleDisplayMode(.inline)
        }.onAppear {
            scene.background.contents = (colorScheme == .dark ? UIColor.black : UIColor.white)
        }
        .onChange(of: selectedBrain, initial: true) {
            Task {
                scene = SCNScene()
                scene.background.contents = (colorScheme == .dark ? UIColor.black : UIColor.white)
                withAnimation {
                    loadingBrain = true
                }
                let brainConverter = BrainConverter(environment: environment, hemisphere: $selectedHemisphere, roi: $selectedRoi, image: .constant(""))
                scene = await brainConverter.createScene()
                scene.background.contents = (colorScheme == .dark ? UIColor.black : UIColor.white)
                
                withAnimation() {
                    loadingBrain = false
                }
            }
        }.sheet(isPresented: $explanation.show) {
            /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-display-a-bottom-sheet ; 04.01.24 12:16
            ExplanationSheet(sheetTitle: $explanation.title, sheetDescription: $explanation.description)
        }
    }
}

#Preview {
    VisualizeRoiView()
}
