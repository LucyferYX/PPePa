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

struct PostMapView: View {
    @State private var region: MKCoordinateRegion
    private var point: IdentifiablePoint

    init(geopoint: CLLocationCoordinate2D) {
        _region = State(initialValue: MKCoordinateRegion(center: geopoint, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
        point = IdentifiablePoint(coordinate: geopoint)
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [point]) { point in
            MapMarker(coordinate: point.coordinate, tint: .red)
        }
        .gesture(MagnificationGesture()
            .onChanged { value in
                let delta = 0.5 / value.magnitude
                region.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            }
        )
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "MapPickerView", key: "currentView")
        }
    }
}
