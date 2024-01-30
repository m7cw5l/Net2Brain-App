//
//  ImageGridItemSelectable.swift
//  Net2Brain
//
//  Created by Marco Weßel on 10.01.24.
//

import SwiftUI

struct ImageGridItemSelectable: View {
    
    @State var pipelineParameters: PipelineParameters
        
    var basePath: String
    var name: String
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: UIImage(contentsOfFile: "\(basePath)/\(name).jpg") ?? UIImage()).resizable()
                .scaledToFill()
            if pipelineParameters.datasetImages.contains(name) {
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large).padding(2).foregroundStyle(Color.accentColor)
            } else {
                Image(systemName: "circle")
                    .imageScale(.large).padding(2).foregroundStyle(Color.gray)
            }
        }.onTapGesture {
            if pipelineParameters.datasetImages.contains(name) {
                pipelineParameters.datasetImages.removeAll { $0 == name }
            } else {
                pipelineParameters.datasetImages.append(name)
            }
        }
    }
}

#Preview {
    ImageGridItemSelectable(pipelineParameters: PipelineParameters(), basePath: "", name: "")
}
