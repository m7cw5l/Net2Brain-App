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
    
    
    @State private var showExplaination = false
        
    var body: some View {
        NavigationStack {
            VStack {
                // https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-two-views-the-same-width-or-height#:~:text=SwiftUI%20makes%20it%20easy%20to,for%20a%20GeometryReader%20or%20similar.; 16.10.23 16:05
                HStack {
                    VStack {
                        Text("Region of Interest").font(.headline)
                        Picker("ROI", selection: $selectedRoi) {
                            Label("All ROIs", systemImage: "brain").tag(ROI.all)
                            Label("Visual", systemImage: "eyes").tag(ROI.visual)
                            Label("Body", systemImage: "figure.stand").tag(ROI.body)
                            Label("Face", systemImage: "face.smiling").tag(ROI.face)
                            Label("Place", systemImage: "map").tag(ROI.place)
                            Label("Word", systemImage: "text.bubble").tag(ROI.word)
                            Label("Anatomical", systemImage: "figure.run").tag(ROI.anatomical)
                        }
                    }.padding(.vertical)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
                    .clipShape(.rect(cornerRadius: 16))
                    
                    VStack {
                        Text("Hemisphere").font(.headline)
                        Picker("Hemisphere", selection: $selectedHemisphere) {
                            Text("Left").tag("left")
                            Text("Right").tag("right")
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
                            Text("3D model is being generated").font(.callout)
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .background()
                        .zIndex(2.0)
                        .allowsHitTesting(false)
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background()
                .clipShape(.rect(cornerRadius: 16))
                
                Button("Explain what I see here", systemImage: "questionmark.circle", action: {
                    showExplaination.toggle()
                }).padding([.top])
            }
            .padding()
            .background(Color(uiColor: UIColor.secondarySystemBackground))
                .navigationTitle("Visualize vertices")
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
        }
        .alert("What do you see here", isPresented: $showExplaination) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Lorem ipsum, dolor sit amet consectetur adipisicing elit. Accusamus, in aut soluta blanditiis fuga doloribus voluptatem, tenetur possimus, earum fugit consequuntur. Quam maiores enim nemo? Mollitia suscipit officiis unde nobis.")
        }
    }
}

#Preview {
    VisualizeRoiView()
}
