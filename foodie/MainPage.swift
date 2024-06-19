//
//  MainPage.swift
//  foodie
//
//  Created by Aidan James on 2024-06-18.
//

import SwiftUI
import CoreLocation
import MapKit

extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
}

extension MKCoordinateRegion {
    static let boston = MKCoordinateRegion (
        center: CLLocationCoordinate2D(
            latitude: 42.360756, 
            longitude: -71.057279
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1
        )
    )
    
    static let northShore = MKCoordinateRegion (
        center: CLLocationCoordinate2D(
            latitude: 42.547408,
            longitude: -70.870085
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.5,
            longitudeDelta: 0.5
        )
    )
}

struct ItemInfoView: View {
    @State private var lookAroundScene: MKLookAroundScene?
    var selectedResult: MKMapItem
    var route: MKRoute?
    
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
        }
    }
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedResult.name ?? "")")
                    if let travelTime {
                        Text(travelTime)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(10)
            }
            .onAppear{
                getLookAroundScene()
            }
            .onChange(of: selectedResult) {
                getLookAroundScene()
            }
    }
}

struct ButtonView: View {
    @Binding var searchResult: [MKMapItem] // results from searching
    @Binding var position: MapCameraPosition // positioning of the maps camera
    
    var visibleRegion: MKCoordinateRegion? // for searching inside of frame
    
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = visibleRegion ?? MKCoordinateRegion(
            center: .parking,
            span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125))
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResult = response?.mapItems ?? []
        }
    }
    
    var body: some View {
        HStack {
            Button {
                search(for: "playground")
            } label: {
                Label("Playgrounds", systemImage: "figure.and.child.holdinghands")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                search(for: "beach")
            } label: {
                Label("Beaches", systemImage: "beach.umbrella")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                position = .region(.boston)
            } label : {
                Label("Boston", systemImage: "building.2")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                position = .region(.northShore)
            } label : {
                Label("Boston", systemImage: "water.waves")
            }
            .buttonStyle(.borderedProminent)
        }
        .labelStyle(.iconOnly)
    }
}


struct MainPage: View {
    @State private var searchResults: [MKMapItem] = [] // array of search results
    @State private var position: MapCameraPosition = .automatic // setting camera position to screen
    @State private var visibleRegion: MKCoordinateRegion? // frame position (visible)
    @State private var selectedResult: MKMapItem? // holding user selected map item
    @State private var route: MKRoute? // route to selected destination
    
    // getting directions to a selected route
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark (coordinate: .parking))
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
    
    var body: some View {
        ZStack {
            // map or request location view
            Map(position: $position, selection: $selectedResult) {
                // for each search result, add a marker
                ForEach(searchResults, id: \.self) { result in
                    Marker(item: result)
                }
                .annotationTitles(.hidden)
                
                // if a route exists, make a line there
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
                // users location
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            // allows us to insert elements at the bottom without interferance
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        // if a map item is selected
                        if let selectedResult {
                            ItemInfoView(selectedResult: selectedResult, route: route)
                                .frame(height: 128)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding([.top, .horizontal])
                        }
                        ButtonView(searchResult: $searchResults, position: $position, visibleRegion: visibleRegion)
                            .padding(5)
                    }
                    Spacer()
                }
                .background(.thinMaterial)
            }
            // when search results change (button click) position is adjusted
            .onChange(of: searchResults) {
                position = .automatic // setting postion to frame if user changes location and requests new places
            }
            // when item selected changes (or is selected) get directions to said item
            .onChange(of: selectedResult) {
                getDirections()
            }
            // when maps frame (camera) changes, adjust visible region
            .onMapCameraChange { context in
                visibleRegion = context.region
            }
            // controlls available to the user
            .mapControls {
                MapUserLocationButton()
                MapCompass(.always)
                MapScaleView(.alwaysEnabled)
            }
        }
    }
}

#Preview {
    MainPage()
}
