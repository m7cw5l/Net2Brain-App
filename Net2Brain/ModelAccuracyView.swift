//
//  ModelAccuracyView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI
import Charts

struct ModelAccuracyView: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var selectedHemisphere = "left"
    @State private var selectedRoi = ROI.visual
    var mlModel: MLModelName
    
    //let mlPredict = MLPredict(with: modelContext)
    
    let chartData = [
        (roi: "All", hemisphere: "left", correlation: 0.45),
        (roi: "All", hemisphere: "right",  correlation: 0.38),
        (roi: "Visual", hemisphere: "left",  correlation: 0.45),
        (roi: "Visual", hemisphere: "right",  correlation: 0.38),
        (roi: "Body", hemisphere: "left",  correlation: 0.45),
        (roi: "Body", hemisphere: "right",  correlation: 0.38),
        (roi: "Face", hemisphere: "left",  correlation: 0.45),
        (roi: "Face", hemisphere: "right",  correlation: 0.38),
        (roi: "Place", hemisphere: "left",  correlation: 0.45),
        (roi: "Place", hemisphere: "right",  correlation: 0.38),
        (roi: "Word", hemisphere: "left",  correlation: 0.45),
        (roi: "Word", hemisphere: "right",  correlation: 0.38),
        (roi: "Anatomical", hemisphere: "left",  correlation: 0.45),
        (roi: "Anatomical", hemisphere: "right",  correlation: 0.38)
    ]
    
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
                
                if selectedRoi == .all {
                    ContentUnavailableView {
                        Label("3D not implemented yet", systemImage: "rotate.3d")
                    } description: {
                        Text("Here you will see an interactive SceneView when implemented\n\nSelected Hemisphere: \(selectedHemisphere)")
                    }.frame(maxHeight: .infinity)
                        .background()
                        .clipShape(.rect(cornerRadius: 16))
                } else {
                    /// https://developer.apple.com/wwdc22/10137; 24.10.23 10:09
                    // bars vertical
                    /*Chart {
                        ForEach(chartData, id: \.roi) {
                            BarMark(
                                x: .value("ROI", $0.roi),
                                y: .value("Mean Pearson's r", $0.correlation)
                            ).foregroundStyle(by: .value("Hemisphere", $0.hemisphere))
                                .position(by: .value("Hemisphere", $0.hemisphere))
                        }
                    }
                    .chartXAxisLabel("ROIs")
                    .chartYAxisLabel("Mean Pearson's r")
                    //.chartYScale(domain: 0...1)
                    .chartForegroundStyleScale([
                        "left": .blue,
                        "right": .orange
                    ])
                    .padding()
                    .background()
                    .clipShape(.rect(cornerRadius: 16))*/
                    
                    // bars horizontal
                    Chart {
                        ForEach(chartData, id: \.roi) {
                            BarMark(
                                x: .value("Mean Pearson's r", $0.correlation),
                                y: .value("ROI", $0.roi)
                            ).foregroundStyle(by: .value("Hemisphere", $0.hemisphere))
                                .position(by: .value("Hemisphere", $0.hemisphere))
                        }
                    }
                    .chartXAxisLabel("Mean Pearson's r")
                    //.chartXScale(domain: 0...1)
                    .chartYAxisLabel("ROIs")
                    .chartForegroundStyleScale([
                        "left": .blue,
                        "right": .orange
                    ])
                    .padding()
                    .background()
                    .clipShape(.rect(cornerRadius: 16))
                }
                
                Button("Explain what I see here", systemImage: "questionmark.circle", action: {
                    
                }).padding([.top])
            }.padding()
            .background(Color(uiColor: UIColor.secondarySystemBackground))
            .navigationTitle("Encoding accuracy")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                /*mlPredict.loadImageFromUrl("https://upload.wikimedia.org/wikipedia/commons/8/8e/Hauskatze_langhaar.jpg", completionHandler: { image in
                    if let image = image {
                        //mlPredict.predictResNet18(pixelBuffer: mlPredict.buffer(from: image)!)
                    }
                })*/
            }
        }
    }
}

#Preview {
    ModelAccuracyView(mlModel: .resnet18)
}
