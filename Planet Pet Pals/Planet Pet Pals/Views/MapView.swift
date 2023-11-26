//
//  MapView.swift
//  Planet Pet Pals
//
//  Created by Liene on 21/11/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var showMapView: Bool
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    var body: some View {
        NavigationView {
            VStack {
                CustomNavigationBar(
                    title: "Map",
                    leftButton: NavigationButton(
                        action: { self.showMapView = false },
                        imageName: "chevron.up",
                        buttonText: "",
                        imageColor: Color(hex: "F9EEE8"),
                        buttonColor: Color(hex: "FFFAF7"),
                        buttonInvisible: false
                    ),
                    rightButton: NavigationButton(
                        action: {},
                        imageName: "chevron.up",
                        buttonText: "",
                        imageColor: Color(hex: "F9EEE8"),
                        buttonColor: Color(hex: "FFFAF7"),
                        buttonInvisible: false
                    )
                )

                ZStack {
                    MainBackground()
                    Map(coordinateRegion: $region)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .transition(.move(edge: .bottom))
    }
}


//struct MapPreviews: PreviewProvider {
//    static var previews: some View {
//        MapView(showMapView: .constant(true))
//    }
//}
