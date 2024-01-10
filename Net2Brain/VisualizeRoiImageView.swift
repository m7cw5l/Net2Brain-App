//
//  VisualizeRoiImageView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI
import SceneKit

struct VisualizeRoiImageView: View {
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
    
    let pathTrainingImages = Bundle.main.resourcePath!
    
    @Environment(\.self) var environment
    @Environment(\.colorScheme) var colorScheme
    @State private var backgroundColor: Color = .white
    
    @State private var selectedRoi: ROI = .all
    @State private var selectedHemisphere = "left"
    
    @State private var loadingBrain = true
        
    @State private var scene = SCNScene()
    @State private var minColor = 0
    @State private var maxColor = 0
    
    @State var selectedImage: String = "image00001"
    @State private var selectNewImage = false
    
    var selectedBrain: [String] {[
        selectedRoi.rawValue,
        selectedHemisphere,
        selectedImage
    ]}
    
    @State var explanation = Explanation(title: "explanation.general.alert.title", description: "explanation.visualization.fmri", show: false)
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    VStack {
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
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                    
                    ZStack {
                        ///https://stackoverflow.com/a/73710494; 19.10.23 13:06
                        Color.clear
                        .overlay (
                            Image(uiImage: UIImage(contentsOfFile: "\(pathTrainingImages)/\(selectedImage).png") ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        )
                        .clipped()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
                    .clipShape(.rect(cornerRadius: 16))
                    .onTapGesture {
                        selectNewImage.toggle()
                    }
                
                }.fixedSize(horizontal: false, vertical: true)
                
                ZStack {
                    SceneView(
                        scene: scene,
                        pointOfView: nil,
                        options: [.allowsCameraControl, .autoenablesDefaultLighting],
                        delegate: nil
                    ).scaledToFit()
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
                }//.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background()
                .clipShape(.rect(cornerRadius: 16))
                
                VStack {
                    LinearGradient(colors: heatmap.map { Color(uiColor: $0) }, startPoint: .leading, endPoint: .trailing)
                        .frame(height: 32.0)
                        .clipShape(.rect(cornerRadius: 16))
                    HStack {
                        if !loadingBrain {
                            Text("\(minColor)")
                            Spacer()
                            Text("0")
                            Spacer()
                            Text("\(maxColor)")
                        } else {
                            Text("loading.data")
                        }
                    }
                }
                
                Button("explanation.general.button.title", systemImage: "questionmark.circle", action: {
                    explanation.show.toggle()
                }).padding([.top])
            }.padding()
            .background(Color(uiColor: UIColor.secondarySystemBackground))
            .navigationTitle("view.fmri.visualize.title")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $selectNewImage) {
                ImageSelectorView(selectedImage: $selectedImage)
            }
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
                let brainConverter = BrainConverter(environment: environment, hemisphere: $selectedHemisphere, roi: $selectedRoi, image: $selectedImage)
                scene = await brainConverter.createScene()
                scene.background.contents = (colorScheme == .dark ? UIColor.black : UIColor.white)
                let extremes = brainConverter.getColorExtremes()
                minColor = extremes.min
                maxColor = extremes.max
                withAnimation {
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
    VisualizeRoiImageView()
}
