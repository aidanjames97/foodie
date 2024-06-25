//
//  ContentView.swift
//  foodie
//
//  Created by Aidan James on 2024-06-17.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @State private var locationAllowed = false
    @StateObject private var viewModel = MapPageModel()
    
    var body: some View {
        return Group {
            if locationAllowed {
                MapPage(viewModel: viewModel)
            } else {
                Landing(locationAllowed: $locationAllowed, viewModel: viewModel)
            }
        }
    }
}

// model for user location
final class MapPageModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // ui will update when this is changed due to it being published
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.974, longitude: -82.405),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    var locationManager: CLLocationManager? // optional location manager (if location accessable)
    
    // checking if location is enabled
    func checkLocEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            // location enabled
            locationManager = CLLocationManager() // will auto call did loc change
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
        }
    }
    
    // can we use location
    func isEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            return true
        }
        return false
    }
    
    // checking for auth
    private func checkLocAuth() {
        guard let locationManager = locationManager else { return } // unwrap location manager
        
        switch locationManager.authorizationStatus { // check auth status
        case .notDetermined:
            // need to ask permission
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location restricted")
        case .denied:
            print("location denied")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(
                center: locationManager.location!.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
        @unknown default:
            print("location status unknown")
        }
    }
    
    // checking for change in location services
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocAuth()
    }
}

#Preview {
    ContentView()
}
