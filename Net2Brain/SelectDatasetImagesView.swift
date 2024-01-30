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
    
    @Binding var path: NavigationPath
        
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]
    
    let pathImages = Bundle.main.resourcePath!
    
    var body: some View {
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
            
            Button(action: {
                path.append(PipelineView.mlModel)
            }, label: {
                Text("button.next.title").frame(maxWidth: .infinity).padding(6)
            }).buttonStyle(BorderedProminentButtonStyle())
                .padding()
                .disabled(pipelineParameters.datasetImages.count == 0)
            
        }.background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("view.pipeline.dataset.images.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                RestartPipelineButton(pipelineParameters: pipelineParameters, pipelineData: pipelineData, path: $path)
            }
            .onChange(of: pipelineParameters.datasetImages) {
                pipelineData.resetAll()
            }
    }
    
    
}

#Preview {
    SelectDatasetImagesView(pipelineParameters: PipelineParameters(), pipelineData: PipelineData(), path: .constant(NavigationPath()))
}
