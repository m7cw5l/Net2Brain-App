//
//  ImagesOverviewView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI

struct ImagesOverviewView: View {
    //https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid-using-lazyvgrid-and-lazyhgrid; 16.10.23 14:52
    
    let data = (1...20).map { String(format: "image%05d.png", $0) }
    let images78 = (1...78).map { String(format: "78images_%05d.jpg", $0) }
    let images92 = (1...92).map { String(format: "92images_%05d.jpg", $0) }

    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]
    
    /*let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]*/
    
    @State var imageSet = "trainingImages"
    
    let pathImages = Bundle.main.resourcePath!
    
    var imageData: [String] {
        switch imageSet {
        case "trainingImages":
            return data
        case "78images":
            return images78
        case "92images":
            return images92
        default:
            return data
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("images.set.selection.title", selection: $imageSet) {
                    Text("images.set.fmri").tag("trainingImages")
                    Text("pipeline.datasets.78images.title").tag("78images")
                    Text("pipeline.datasets.92images.title").tag("92images")
                }.pickerStyle(.segmented)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(imageData, id: \.self) { name in
                            Image(uiImage: UIImage(contentsOfFile: "\(pathImages)/\(name)") ?? UIImage()).resizable()
                                .scaledToFill()
                        }
                    }.padding(.horizontal)
                }
            }
            .navigationTitle("view.images.title")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ImagesOverviewView()
}
