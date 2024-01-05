//
//  MapPickerView.swift
//  Planet Pet Pals
//
//  Created by Liene on 31/12/2023.
//

import SwiftUI
import MapKit

struct MapPickerView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    var selectedRegion: String
    
    var region: MKCoordinateRegion {
        let ((latitude, longitude), (latitudeDelta, longitudeDelta)) = regions[selectedRegion]!
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        
        mapView.setRegion(region, animated: true)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setCenter(centerCoordinate, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapPickerView

        init(_ parent: MapPickerView) {
            self.parent = parent
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            let coordinate = (gestureRecognizer.view as? MKMapView)?.convert(location, toCoordinateFrom: gestureRecognizer.view)
            
            let allAnnotations = (gestureRecognizer.view as? MKMapView)?.annotations
            (gestureRecognizer.view as? MKMapView)?.removeAnnotations(allAnnotations ?? [])
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate!
            (gestureRecognizer.view as? MKMapView)?.addAnnotation(annotation)
            
            parent.centerCoordinate = coordinate!
            
            print("Tapped at latitude: \(coordinate!.latitude), longitude: \(coordinate!.longitude)")
        }
    }
}
