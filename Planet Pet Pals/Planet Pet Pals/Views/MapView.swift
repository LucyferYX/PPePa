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
                    Map(coordinateRegion: .constant(region), annotationItems: posts) { post in
                        MapAnnotation(coordinate: post.location) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
//            .onAppear {
//                Task {
//                    do {
//                        posts = try await PostManager.shared.getAllPosts()
//                    } catch {
//                        print("Failed to fetch posts: \(error)")
//                    }
//                }
//            }
        }
        .transition(.move(edge: .bottom))
    }
}

//struct MapView: View {
//    @Binding var showMapView: Bool
//    @AppStorage("selectedRegion") var selectedRegion: String = "Europe" // Default value
//    @State var region: MKCoordinateRegion
//
//    var body: some View {
//        let ((latitude, longitude), (latitudeDelta, longitudeDelta)) = regions[selectedRegion]!
//        let region = MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
//            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
//        )
//
//        return NavigationView {
//            VStack {

//
//                ZStack {
//                    MainBackground()
//                    Map(coordinateRegion: .constant(region))
//                        .edgesIgnoringSafeArea(.all)
//                }
//            }
//        }
//        .transition(.move(edge: .bottom))
//    }
//}

//struct MapView: View {
//    @Binding var showMapView: Bool
//    @EnvironmentObject private var viewModel: MapViewModel
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                MainNavigationBar(
//                    title: "Map",
//                    leftButton: LeftNavigationButton(
//                        action: { self.showMapView = false },
//                        imageName: "chevron.up",
//                        buttonText: "Back",
//                        imageInvisible: false,
//                        textInvisible: false
//                    ),
//                    rightButton: RightNavigationButton(
//                        action: {},
//                        imageName: "slider.horizontal.3",
//                        buttonText: "Back",
//                        imageInvisible: false,
//                        textInvisible: true
//                    )
//                )
//
//                ZStack {
//                    MainBackground()
//                    Map(coordinateRegion: $viewModel.region)
//                        .edgesIgnoringSafeArea(.all)
//                }
//            }
//        }
//        .transition(.move(edge: .bottom))
//    }
//}


// MARK: For creating post
struct SelectLocationView: UIViewRepresentable {
    @Binding var selectedLocation: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedLocation
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotation(annotation)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: SelectLocationView

        init(_ parent: SelectLocationView) {
            self.parent = parent
        }

        @objc func mapTapped(_ recognizer: UITapGestureRecognizer) {
            let mapView = recognizer.view as! MKMapView
            let point = recognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.selectedLocation = coordinate
        }
    }
}
