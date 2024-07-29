//
//  AddressSelectionView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 24.07.2024.
//

import SwiftUI
import CoreLocation
import MapKit

struct AddressSelectionView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var address: String = ""
    @State private var annotations: [MKPointAnnotation] = []
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .padding()
                }
                
                TextField("Введите адрес", text: $address)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: {
                    locationManager.requestLocation()
                }) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
            .padding()

            ZStack(alignment: .bottom) {
                MapView(annotations: annotations, selectedCoordinate: $selectedCoordinate) { coordinate in
                    guard !coordinate.latitude.isNaN && !coordinate.longitude.isNaN else {
                        print("Некорректные координаты: \(coordinate)")
                        return
                    }
                    locationManager.reverseGeocode(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { address in
                        DispatchQueue.main.async {
                            self.address = address
                        }
                    }
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = address
                    DispatchQueue.main.async {
                        self.annotations = [annotation]
                    }
                }
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    Button(action: {
                        // Логика сохранения адреса
                        print("Сохранить адрес: \(address)")
                    }) {
                        Text("Сохранить адрес")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.bottom)
                }
            }
        }
        .navigationTitle("Выбор адреса")
        .onChange(of: locationManager.address) { newAddress in
            if let newAddress = newAddress, let location = locationManager.location {
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = newAddress
                DispatchQueue.main.async {
                    self.annotations = [annotation]
                    self.address = newAddress
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}

struct AddressSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddressSelectionView()
    }
}
