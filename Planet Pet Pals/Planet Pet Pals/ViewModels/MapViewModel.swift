//
//  MapViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 18/12/2023.
//

import SwiftUI
import MapKit

@MainActor
class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion

    init(region: String) {
        let ((latitude, longitude), (latitudeDelta, longitudeDelta)) = regions[region]!
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }
}
