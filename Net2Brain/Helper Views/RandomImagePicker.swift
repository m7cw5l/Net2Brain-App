//
//  PickRandomImagesButtonRow.swift
//  Net2Brain
//
//  Created by Marco Weßel on 10.01.24.
//

import SwiftUI

struct RandomImagePicker: View {
    
    @State var pipelineParameters: PipelineParameters
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach([5, 10, 15, 20, 25, 30, 35, 40], id: \.self) { number in
                    Button(action: {
                        selectRandomImages(number)
                    }, label: {
                        Text("\(number)").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                }
            }.padding(.horizontal)
        }
    }
    
    func selectRandomImages(_ count: Int) {
        var allImages = [String]()
        for category in pipelineParameters.dataset.images {
            allImages.append(contentsOf: category.images)
        }
        pipelineParameters.datasetImages.removeAll()
        var selectedImages = [String]()
        for _ in 0..<count {
            var newValidImage = false
            while !newValidImage {
                let selectedImage = allImages.randomElement() ?? ""
                if !selectedImages.contains(selectedImage) {
                    selectedImages.append(selectedImage)
                    newValidImage = true
                }
            }
            
        }
        selectedImages = selectedImages.sorted()
        print(selectedImages)
        pipelineParameters.datasetImages.append(contentsOf: selectedImages)
    }
}

#Preview {
    RandomImagePicker(pipelineParameters: PipelineParameters())
}
