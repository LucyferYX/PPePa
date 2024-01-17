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
    @State private var showPostView = false
    @State private var currentPost: Post? = nil

    // Shows selected region by user on the map
    var region: MKCoordinateRegion {
        let ((latitude, longitude), (latitudeDelta, longitudeDelta)) = regions[selectedRegion]!
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    NavigationBar
                    ZStack {
                        MainBackground()
                        // The map view
                        Map(coordinateRegion: .constant(region), annotationItems: posts) { post in
                            MapAnnotation(coordinate: post.location) {
                                MapAnnotationView()
                                    .onTapGesture {
                                        currentPost = post
                                        showPostView = true
                                    }
                            }
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                }
                // Gets all the posts to show on map
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
            // Tapping post will open post view
            if showPostView, let postId = currentPost?.postId {
                Text("")
                    .fullScreenCover(isPresented: $showPostView) {
                        PostView(showPostView: $showPostView, postId: postId)
                    }
            }
        }

    }
}


//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView(showMapView: .constant(true))
//    }
//}


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
                imageInvisible: true,
                textInvisible: true
            )
        )
    }
}
