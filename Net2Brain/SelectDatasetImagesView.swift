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
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]
    
    let pathImages = Bundle.main.resourcePath!
    
    var body: some View {
        NavigationStack {
            VStack {
                PipelineSelectionView(pipelineParameters: $pipelineParameters, currentlySelectedParameter: .images)
                
                HStack {
                    Button(action: {
                        pipelineParameters.datasetImages.removeAll()
                    }, label: {
                        Text("button.deselect.all.title").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                        .padding(.horizontal)
                        .disabled(pipelineParameters.datasetImages.count == 0)
                }
                
                RandomImagePicker(pipelineParameters: pipelineParameters)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2, pinnedViews: .sectionHeaders) {
                        ForEach(pipelineParameters.dataset.images, id: \.name) { imageCategory in
                            Section(header: ImageGridHeaderSelectable(pipelineParameters: pipelineParameters, category: imageCategory)) {
                                ForEach(imageCategory.images, id: \.self) { name in
                                    ImageGridItemSelectable(pipelineParameters: pipelineParameters, basePath: pathImages, name: name)
                                }
                            }
                        }
                    }.padding(.horizontal)
                }
                
                NavigationLink(destination: {
                    SelectMLModelView(pipelineParameters: pipelineParameters, pipelineData: pipelineData)
                }, label: {
                    Text("button.next.title").frame(maxWidth: .infinity).padding(6)
                }).buttonStyle(BorderedProminentButtonStyle())
                    .padding()
                    .disabled(pipelineParameters.datasetImages.count == 0)
            }.background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("view.pipeline.dataset.images.title")
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: pipelineParameters.datasetImages) {
                    pipelineData.resetPredictionOutputs()
                    pipelineData.resetDistanceMatrices()
                }
        }
    }
    
    
}

#Preview {
    SelectDatasetImagesView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData())
}
