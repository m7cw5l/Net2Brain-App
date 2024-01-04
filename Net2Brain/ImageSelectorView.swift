//
//  ImageSelectorView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 20.10.23.
//

import SwiftUI

struct ImageSelectorView: View {
    //https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid-using-lazyvgrid-and-lazyhgrid; 16.10.23 14:52
    
    let data = (1...20).map { String(format: "image%05d", $0) }

    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]
    
    /*let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]*/
    
    let pathTrainingImages = Bundle.main.resourcePath!
    
    @Binding var selectedImage: String
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(data, id: \.self) { name in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: UIImage(contentsOfFile: "\(pathTrainingImages)/\(name).png") ?? UIImage()).resizable()
                                .scaledToFill()
                            if name == selectedImage {
                                Button {
                                    
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                }.padding(2)
                                    .tint(Color.accentColor)
                            }
                        }.onTapGesture {
                            selectedImage = name
                            dismiss()
                        }
                    }
                }.padding(.horizontal)
            }.navigationTitle("view.image.select.title")
                .navigationBarTitleDisplayMode(.inline)
        }
            
    }
}

#Preview {
    ImageSelectorView(selectedImage: .constant("image00001"))
}
