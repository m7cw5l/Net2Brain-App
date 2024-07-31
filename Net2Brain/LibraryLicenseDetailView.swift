//
//  AcknowledgementDetailView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 22.07.24.
//

import SwiftUI

/// view for displaying the license text of a library
struct LibraryLicenseDetailView: View {
    var libraryLicense: LibraryLicense
    
    var body: some View {
        ScrollView {
            Text(libraryLicense.licenseText).padding()
        }.navigationTitle(libraryLicense.libraryName)
    }
}

#Preview {
    LibraryLicenseDetailView(libraryLicense: LibraryLicense(libraryName: "", licenseText: ""))
}
