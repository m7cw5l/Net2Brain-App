//
//  ImagesOverviewView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI

struct ImagesOverviewView: View {
    @Binding var path: NavigationPath
    
    //https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid-using-lazyvgrid-and-lazyhgrid; 16.10.23 14:52
    
    let data = (1...20).map { String(format: "image%05d.png", $0) }

    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]
    
    @State var imageSet = "trainingImages"
    
    let pathImages = Bundle.main.resourcePath!
    
    var imageData: [N2BImageCategory] {
        switch imageSet {
        case "78images":
            return images78
        case "92images":
            return images92
        default:
            return images78
        }
    }
    
    var body: some View {
        VStack {
            Picker("images.set.selection.title", selection: $imageSet) {
                Text("images.set.fmri").tag("trainingImages")
                Text("pipeline.datasets.78images.title").tag("78images")
                Text("pipeline.datasets.92images.title").tag("92images")
            }.pickerStyle(.segmented)
                .padding(.horizontal)
            
            ScrollView {
                if imageSet == "trainingImages" {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(data, id: \.self) { name in
                            Image(uiImage: UIImage(contentsOfFile: "\(pathImages)/\(name).png") ?? UIImage()).resizable()
                                .scaledToFill()
                        }
                    }.padding(.horizontal)
                } else {
                    LazyVGrid(columns: columns, spacing: 2, pinnedViews: .sectionHeaders) {
                        ForEach(imageData, id: \.name) { imageCategory in
                            Section(header: ImageGridHeader(category: imageCategory)) {
                                ForEach(imageCategory.images, id: \.self) { name in
                                    Image(uiImage: UIImage(contentsOfFile: "\(pathImages)/\(name).jpg") ?? UIImage()).resizable()
                                        .scaledToFill()
                                }
                            }
                        }
                    }.padding(.horizontal)
                }
            }
        }
        .navigationTitle("view.images.title")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ImagesOverviewView(path: .constant(NavigationPath()))
}
