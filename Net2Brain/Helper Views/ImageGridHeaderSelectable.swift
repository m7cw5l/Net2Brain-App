//
//  ImageGridHeader.swift
//  Net2Brain
//
//  Created by Marco Weßel on 10.01.24.
//

import SwiftUI

/// view for displaying a header for a image category in a categorized image picker with the option of (de-)selecting the image category
/// - Parameters:
///   - category: the image category corresponding to the header
struct ImageGridHeaderSelectable: View {
    
    @EnvironmentObject var pipelineParameters: PipelineParameters
    
    var category: N2BImageCategory
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(category.name)).font(.headline)
            
            Spacer()
            if pipelineParameters.datasetImages.contains(category.images) {
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large).foregroundStyle(Color.accentColor)
            } else if Array(Set(pipelineParameters.datasetImages).intersection(category.images)).count > 0 {
                /// https://stackoverflow.com/a/63194434 ; 10.01.2024 16:50
                Image(systemName: "minus.circle.fill")
                    .imageScale(.large).foregroundStyle(Color.accentColor)
            } else {
                Image(systemName: "circle")
                    .imageScale(.large).foregroundStyle(Color.gray)
            }
        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 2)
            .padding(.top)
            .padding(.bottom, 8)
            .background(Color(uiColor: .systemGroupedBackground))
            .onTapGesture {
            if pipelineParameters.datasetImages.contains(category.images) {
                pipelineParameters.datasetImages.removeAll { category.images.contains($0) }
            } else {
                pipelineParameters.datasetImages.removeAll { category.images.contains($0) }
                pipelineParameters.datasetImages.append(contentsOf: category.images)
            }
        }
    }
}

#Preview {
    ImageGridHeaderSelectable(category: N2BImageCategory(name: "Test", images: []))
}
