//
//  MapPage.swift
//  foodie
//
//  Created by Aidan James on 2024-06-19.
//

import SwiftUI
import MapKit

struct MapPage: View {
    @StateObject private var viewModel = MapPageModel() // model for location
    @State private var radius: Double = 15 // slider value
    @State private var isEditing = false // is slider being edited
    @State private var position: MapCameraPosition = .automatic  // setting camera position to screen
    @State private var searchResults: [MKMapItem] = [] // restaurants
    @State private var selectedResult: MKMapItem? // user selected restaurant
    @State private var route: MKRoute? // route to selected destination
    @State private var showLookAround = false // should look around be displayed
    @State private var randomize = false // can a restaurant be randomly selected (init false)
    
    // getting directions to a selected route
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark (coordinate: viewModel.region.center))
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
    
    // choose a restaurant
    func chooseRestaurant() {
        let randInx = Int.random(in: 0..<searchResults.count) // random
        selectedResult = searchResults[randInx] // set selected to random
        searchResults.removeAll() // clear all elements
        searchResults.append(selectedResult!) // add selected back so it is displayed
    }
    
    var body: some View {
        VStack {
            Map(position: $position, selection: $selectedResult) {
                // user icon
                UserAnnotation(anchor: .center) {
                    Label("YOU", systemImage: "person.crop.circle")
                        .labelStyle(.iconOnly)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.gradientBottom)
                        .padding(-2)
                        .background(.gradientTop)
                        .cornerRadius(100)
                }
                // restautant markers
                ForEach(searchResults, id: \.self) { restaurants in
                    Marker(item: restaurants)
                        .annotationTitles(.automatic)
                }
                
                // search radius circle
                MapCircle(center: viewModel.region.center, radius: (radius+1)*250)
                    .foregroundStyle(Color(red: 1, green: 0.384, blue: 0.384, opacity: 0.2))
                    .stroke(.gradientTop)
                
                // drawing route if one has been calculated
                if let route {
                    MapPolyline(route)
                        .stroke(.gradientTop, lineWidth: 4)
                }
            }
            .accentColor(.gradientBottom) // color of user location
            // when map is shown check location
            .onAppear {
                viewModel.checkLocEnabled()
            }
            // declare safe area for bottom elemets
            .safeAreaInset(edge: .bottom) {
                VStack {
                    // if a map item is selected
                    if let selectedResult {
                        ItemInfoView(selectedResult: selectedResult, route: route)
                            .frame(height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    // bottom buttons and slider
                    BottomButtons(searchResults: $searchResults, searchingRegion: MKCoordinateRegion(
                            center: viewModel.region.center,
                            latitudinalMeters: CLLocationDistance(Int(radius*1000)),
                            longitudinalMeters: CLLocationDistance(Int(radius*1000)))
                        )
                    Slider(
                        value: $radius,
                        in: 0...30,
                        step: 1,
                        onEditingChanged: { editing in
                            isEditing = editing
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    // randomize button
                    if randomize {
                        Button {
                            Task { // async task
                                chooseRestaurant()
                            }
                        } label : {
                            Label("Choose For Me!", systemImage: "")
                        }
                        .labelStyle(.titleOnly)
                    }
                }
                .background(.ultraThinMaterial)
                .buttonStyle(.borderedProminent)
            }
            // controls user can use on map
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapScaleView()
            }
            // map will be animated with elevated elements
            .mapStyle(.standard(elevation: .realistic))
            // when we get a new search result (button clicked)
            .onChange(of: searchResults) {
                position = .automatic
                Task {
                    randomize.toggle()
                    route = nil // clear any route which is leftover
                }
            }
            // when item selected changes (or is selected) get directions to said item
            .onChange(of: selectedResult) {
                route = nil
                if selectedResult == nil {
                    // user clicked nothing
                    searchResults = [] // clear array
                }
                // getting directions asyc as to not slow other ui elements
                Task {
                    getDirections()
                }
                
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
    MapPage()
}
