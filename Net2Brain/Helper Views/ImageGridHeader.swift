//
//  ImageGridHeader.swift
//  Net2Brain
//
//  Created by Marco Weßel on 10.01.24.
//

import SwiftUI

struct ImageGridHeader: View {
    
    var category: N2BImageCategory
    
    var body: some View {
        Text(LocalizedStringKey(category.name))
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .font(.headline)
            .padding(.top)
            .padding(.bottom, 6)
            .background()
    }
}

#Preview {
    ImageGridHeader(category: N2BImageCategory(name: "test", images: []))
}
