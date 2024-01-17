//
//  PostMapView.swift
//  Planet Pet Pals
//
//  Created by Liene on 04/01/2024.
//

import SwiftUI
import MapKit

struct IdentifiablePoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// View will show the post's location with marker
struct PostMapView: View {
    @GestureState private var magnification: CGFloat = 1.0
    private var point: IdentifiablePoint

    init(geopoint: CLLocationCoordinate2D) {
        point = IdentifiablePoint(coordinate: geopoint)
    }

    var body: some View {
        let delta = 0.5 / magnification
        let region = MKCoordinateRegion(center: point.coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))

        Map(coordinateRegion: .constant(region), annotationItems: [point]) { point in
            MapAnnotation(coordinate: point.coordinate) {
                MapAnnotationView()
            }
        }
        .gesture(MagnificationGesture()
            .updating($magnification) { currentState, gestureState, _ in
                gestureState = currentState
            }
        )
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "MapPickerView", key: "currentView")
        }
    }
}
