//
//  AcknowledgementsView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 22.07.24.
//

import SwiftUI



struct LibraryLicensesView: View {
    var body: some View {
        List(libraryLicenses, id: \.libraryName) { libraryLicense in
            NavigationLink(destination: {
                LibraryLicenseDetailView(libraryLicense: libraryLicense)
            }, label: {
                Text(libraryLicense.libraryName)
            })
        }.navigationTitle("view.libraries.title")
    }
}

#Preview {
    LibraryLicensesView()
}
