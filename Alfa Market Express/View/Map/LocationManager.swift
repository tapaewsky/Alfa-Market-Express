////
////  LocationManager.swift
////  WareHouse1
////
////  Created by Said Tapaev on 24.07.2024.
////
//
import SwiftUI
import CoreLocation
import MapKit

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
            let servicesEnabled = await locationServicesEnabled()
            if servicesEnabled {
                manager.requestLocation()
            } else {
                print("Службы геопозиции отключены.")
            }
        }
    }
    
    func locationServicesEnabled() async -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func reverseGeocode(location: CLLocation, completion: @escaping (String) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                completion("Не удалось определить адрес")
                return
            }
            if let placemark = placemarks?.first {
                let address = [placemark.thoroughfare, placemark.subThoroughfare, placemark.locality, placemark.administrativeArea, placemark.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                completion(address)
            } else {
                completion("Не удалось определить адрес")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        location = newLocation
        
        DispatchQueue.main.async {
            self.reverseGeocode(location: newLocation) { [weak self] address in
                DispatchQueue.main.async {
                    self?.address = address
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let nsError = error as NSError
        if let clError = CLError.Code(rawValue: nsError.code) {
            switch clError {
            case .denied:
                print("Доступ к геопозиции был отклонен.")
            case .locationUnknown:
                print("Не удалось определить местоположение.")
            default:
                print("Неизвестная ошибка: \(nsError.localizedDescription)")
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
