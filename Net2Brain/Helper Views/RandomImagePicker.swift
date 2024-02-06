//
//  PickRandomImagesButtonRow.swift
//  Net2Brain
//
//  Created by Marco Weßel on 10.01.24.
//

import SwiftUI

struct ImagePickerItem: Hashable {
    let type: String
    let count: Int
}

struct RandomImagePicker: View {
    
    @State var pipelineParameters: PipelineParameters
    
    let items = [
        ImagePickerItem(type: "category", count: 1),
        ImagePickerItem(type: "category", count: 2),
        ImagePickerItem(type: "category", count: 3),
        ImagePickerItem(type: "image", count: 10),
        ImagePickerItem(type: "image", count: 15),
        ImagePickerItem(type: "image", count: 20),
        ImagePickerItem(type: "image", count: 30),
        ImagePickerItem(type: "image", count: 40)
    ]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        if item.type == "category" {
                            selectRandomCategories(item.count)
                        } else {
                            selectRandomImages(item.count)
                        }
                    }, label: {
                        Text(item.type == "image" ? "pipeline.image.picker.image.button.title.\(item.count)" : "pipeline.image.picker.category.button.title.\(item.count)").frame(maxWidth: .infinity).padding(6)
                    }).buttonStyle(BorderedButtonStyle())
                }
            }.padding(.horizontal)
        }
    }
    
    func selectRandomCategories(_ count: Int) {
        pipelineParameters.datasetImages.removeAll()
        var selectedCategories = [N2BImageCategory]()
        for _ in 0..<count {
            var newValidCategory = false
            while !newValidCategory {
                let selectedCategory = pipelineParameters.dataset.images.randomElement() ?? N2BImageCategory(name: "", images: [])
                if !selectedCategories.contains(selectedCategory) {
                    selectedCategories.append(selectedCategory)
                    newValidCategory = true
                }
            }
        }
        var selectedImages = [String]()
        for category in selectedCategories {
            selectedImages.append(contentsOf: category.images)
        }
        selectedImages = selectedImages.sorted()
        pipelineParameters.datasetImages.append(contentsOf: selectedImages)
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
        //print(selectedImages)
        pipelineParameters.datasetImages.append(contentsOf: selectedImages)
    }
}

#Preview {
    RandomImagePicker(pipelineParameters: PipelineParameters())
}
