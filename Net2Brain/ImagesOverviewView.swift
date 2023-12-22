//
//  ImagesOverviewView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.10.23.
//

import SwiftUI

struct ImagesOverviewView: View {
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(data, id: \.self) { name in
                        Image(uiImage: UIImage(contentsOfFile: "\(pathTrainingImages)/\(name).png") ?? UIImage()).resizable()
                            .scaledToFill()
                    }
                }.padding(.horizontal)
            }.navigationTitle("available stimulus images")
                .navigationBarTitleDisplayMode(.inline)
        }
            
    }
}

#Preview {
    ImagesOverviewView()
}
