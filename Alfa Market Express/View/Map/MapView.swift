//
//  MapView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 24.07.2024.
//
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation {
                parent.selectedCoordinate = annotation.coordinate
                parent.geocodeCoordinate(annotation.coordinate)
            }
        }
    }

    var annotations: [MKPointAnnotation]
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    var geocodeCoordinate: (CLLocationCoordinate2D) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
        updateMapRegion(for: uiView)
    }
    
    private func updateMapRegion(for mapView: MKMapView) {
        if let coordinate = selectedCoordinate {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
}
