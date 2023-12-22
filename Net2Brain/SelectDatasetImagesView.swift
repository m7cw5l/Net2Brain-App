//
//  SelectImagesFromDatasetView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 25.11.23.
//

import SwiftUI

struct SelectDatasetImagesView: View {
    
    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    let pathImages = Bundle.main.resourcePath!
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .images)
                
                HStack {
                    Button(action: {
                        pipelineParameters.datasetImages.removeAll()
                        pipelineParameters.datasetImages.append(contentsOf: pipelineParameters.dataset.images)
                    }, label: {
                        Text("Select All").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                        .padding(.leading)
                        .disabled(pipelineParameters.datasetImages.count == pipelineParameters.dataset.images.count)
                    
                    Button(action: {
                        pipelineParameters.datasetImages.removeAll()
                    }, label: {
                        Text("Deselect All").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                        .padding(.trailing)
                        .disabled(pipelineParameters.datasetImages.count == 0)
                }
                //Text("Select random images:").font(.headline)
                HStack {
                    Button(action: {
                        selectRandomImages(5)
                    }, label: {
                        Text("5").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                    
                    Button(action: {
                        selectRandomImages(10)
                    }, label: {
                        Text("10").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                    
                    Button(action: {
                        selectRandomImages(15)
                    }, label: {
                        Text("15").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                    
                    Button(action: {
                        selectRandomImages(20)
                    }, label: {
                        Text("20").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                    
                    Button(action: {
                        selectRandomImages(25)
                    }, label: {
                        Text("25").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                }.padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(pipelineParameters.dataset.images, id: \.self) { name in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: UIImage(contentsOfFile: "\(pathImages)/\(name).jpg") ?? UIImage()).resizable()
                                    .scaledToFill()
                                if pipelineParameters.datasetImages.contains(name) {
                                 Button {
                                 
                                 } label: {
                                 Image(systemName: "checkmark.circle.fill")
                                 .imageScale(.large)
                                 }.padding(2)
                                 .tint(Color.accentColor)
                                 }
                            }.onTapGesture {
                                if pipelineParameters.datasetImages.contains(name) {
                                    pipelineParameters.datasetImages.removeAll { $0 == name }
                                } else {
                                    pipelineParameters.datasetImages.append(name)
                                }
                            }
                        }
                    }.padding(.horizontal)
                }
                
                NavigationLink(destination: {
                    SelectMLModelView(pipelineParameters: pipelineParameters, pipelineData: pipelineData)
                }, label: {
                    Text("Next").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding()
                    .disabled(pipelineParameters.datasetImages.count == 0)
            }.background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("Please select an image")
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: pipelineParameters.datasetImages) {
                    pipelineData.resetPredictionOutputs()
                    pipelineData.resetDistanceMatrices()
                }
        }
    }
    
    func selectRandomImages(_ count: Int) {
        pipelineParameters.datasetImages.removeAll()
        for _ in 0..<count {
            let index = Int.random(in: 0..<pipelineParameters.dataset.images.count)
            pipelineParameters.datasetImages.append(pipelineParameters.dataset.images[index])
        }
    }
}

#Preview {
    SelectDatasetImagesView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData())
}
