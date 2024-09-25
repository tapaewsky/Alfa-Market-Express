////
////  LocationManager.swift
////  WareHouse1
////
////  Created by Said Tapaev on 24.07.2024.
////
//
import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocation?
    @Published var address: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        Task {
            if await locationServicesEnabled() {
                manager.requestLocation()
            } else {
                print("Службы геопозиции отключены.")
            }
        }
    }
    
    func locationServicesEnabled() async -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                self?.address = "Не удалось определить адрес"
                return
            }
            self?.address = self?.formatAddress(from: placemarks)
        }
    }
    
    private func formatAddress(from placemarks: [CLPlacemark]?) -> String? {
        guard let placemark = placemarks?.first else { return nil }
        return [placemark.thoroughfare, placemark.subThoroughfare, placemark.locality, placemark.administrativeArea, placemark.country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        location = newLocation
        reverseGeocode(location: newLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let nsError = error as NSError
        handleLocationError(nsError)
    }
    
    private func handleLocationError(_ error: NSError) {
        if let clError = CLError.Code(rawValue: error.code) {
            switch clError {
            case .denied:
                print("Доступ к геопозиции был отклонен.")
            case .locationUnknown:
                print("Не удалось определить местоположение.")
            default:
                print("Неизвестная ошибка: \(error.localizedDescription)")
            }
        } else {
            print("Ошибка не связана с CoreLocation: \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        case .denied, .restricted:
            print("Пользователь не предоставил разрешение на использование геопозиции.")
        default:
            break
        }
    }
}
