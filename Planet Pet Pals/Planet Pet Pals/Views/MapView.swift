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
    @State private var region: MKCoordinateRegion

    init(showMapView: Binding<Bool>, region: String) {
        _showMapView = showMapView
        let ((latitude, longitude), (latitudeDelta, longitudeDelta)) = regions[region]!
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        ))
    }

    var body: some View {
        NavigationView {
            VStack {
                MainNavigationBar(
                    title: "Map",
                    leftButton: LeftNavigationButton(
                        action: { self.showMapView = false },
                        imageName: "chevron.up",
                        buttonText: "Back",
                        imageInvisible: false,
                        textInvisible: false
                    ),
                    rightButton: RightNavigationButton(
                        action: {},
                        imageName: "slider.horizontal.3",
                        buttonText: "Back",
                        imageInvisible: false,
                        textInvisible: true
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
