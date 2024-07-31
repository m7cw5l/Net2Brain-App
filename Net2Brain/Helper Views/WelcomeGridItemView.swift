//
//  WelcomeGridItemView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 20.10.23.
//

import SwiftUI

/// Grid item used in the main menu with an icon and a title below the icon
/// - Parameters:
///   - icon: the system icon name to be displayed in the cell
///   - title: the title displayed in the cell
struct WelcomeGridItemView: View {
    var icon: String
    var title: String
        
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 60))
                .aspectRatio(contentMode: .fit)
                .fontWeight(.light)
                .foregroundColor(.accentColor)
            Spacer()
            Text(LocalizedStringKey(title))/*.font(.headline)*/
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16.0))
    }
}

#Preview {
    WelcomeGridItemView(icon: "brain.head.profile", title: "Visualize vertices on brain surface map").previewLayout(.sizeThatFits)
}
