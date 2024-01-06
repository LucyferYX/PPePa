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
    @AppStorage("selectedRegion") var selectedRegion: String = "Europe"
    @State var posts: [Post] = []

    var region: MKCoordinateRegion {
        let ((latitude, longitude), (latitudeDelta, longitudeDelta)) = regions[selectedRegion]!
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                NavigationBar
                ZStack {
                    MainBackground()
                    Map(coordinateRegion: .constant(region), annotationItems: posts) { post in
                        MapMarker(coordinate: post.location, tint: .red)
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .onAppear {
                Task {
                    do {
                        posts = try await PostManager.shared.getAllPosts()
                    } catch {
                        print("Failed to fetch posts: \(error)")
                    }
                }
            }
        }
        .transition(.move(edge: .bottom))
        .onAppear() {
            CrashlyticsManager.shared.setValue(value: "MapView", key: "currentView")
        }
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(showMapView: .constant(true))
    }
}


extension MapView {
    private var NavigationBar: some View {
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
    }
}
