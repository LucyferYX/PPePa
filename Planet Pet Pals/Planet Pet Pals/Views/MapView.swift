//
//  MapView.swift
//  Planet Pet Pals
//
//  Created by Liene on 21/11/2023.
//

import SwiftUI

struct MapView: View {
    @Binding var showMapView: Bool

    var body: some View {
        NavigationView {
            VStack {
                CustomNavigationBar(
                    title: "Map",
                    leftButtonAction: { /* code to navigate to MainMenuView */ },
                    rightButtonAction: {},
                    leftButtonSystemImage: "chevron.left",
                    rightButtonSystemImage: "chevron.left",
                    rightButtonInvisible: false
                )
                ZStack {
                    MainBackground()
                    Text("Map View test")
                }
            }
        }
    }
}



struct Previews: PreviewProvider {
    static var previews: some View {
        MapView(showMapView: .constant(false))
    }
}
