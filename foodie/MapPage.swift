//
//  MapPage.swift
//  foodie
//
//  Created by Aidan James on 2024-06-19.
//

import SwiftUI
import MapKit

struct MapPage: View {
    @StateObject var viewModel: MapPageModel
    
    @State private var radius: Double = 10.0 // slider value
    @State private var isEditing = false // is slider being edited
    @State private var position: MapCameraPosition = .automatic  // setting camera position to screen
    @State private var searchResults: [MKMapItem] = [] // restaurants
    @State private var selectedResult: MKMapItem? // user selected restaurant
    @State private var route: MKRoute? // route to selected destination
    @State private var showLookAround = false // should look around be displayed
    @State private var randomize = false // can a restaurant be randomly selected (init false)
    @State private var newRandom = false // user wants a different choice
    @State private var oldSearch: [MKMapItem] = [] // holds old selected restaurants
    @State private var buttonClicked = false // holds if bottom button has been clicked
    
    // getting directions to a selected route
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark (coordinate: viewModel.region.center))
        request.destination = selectedResult
        // async request directions
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
    
    // choose a restaurant (called async)
    func chooseRestaurant() {
        let randInx = Int.random(in: 0..<searchResults.count) // random
        selectedResult = searchResults[randInx] // set selected to random
        oldSearch = searchResults // putting all restaurants in a aux array
        oldSearch.remove(at: randInx) // removing selected as to not be chosen again
        searchResults.removeAll() // clear all elements
        searchResults.append(selectedResult!) // add selected back so it is displayed
    }
    
    // choosing new restaurant
    func chooseNewRestaurant() {
        searchResults = oldSearch
        oldSearch.removeAll()
        chooseRestaurant() // now choose random restaurant
    }
    
    // check for button click
    func checkChange() {
        if buttonClicked {
            selectedResult = nil // remove any existing selections
            randomize = true
            newRandom = false
            buttonClicked = false
        }
    }
    
    var body: some View {
        VStack {
            Map(position: $position, selection: $selectedResult) {
                // user icon on their position
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
                // restautant markers depending on search results
                ForEach(searchResults, id: \.self) { restaurants in
                    Marker(item: restaurants)
                        .annotationTitles(.automatic)
                }
                
                // search radius circle
                MapCircle(center: viewModel.region.center, radius: (radius+1)*500)
                    .foregroundStyle(Color(red: 1, green: 0.384, blue: 0.384, opacity: 0.2))
                    .stroke(.gradientTop)
                
                // drawing route if one has been calculated
                if let route {
                    MapPolyline(route)
                        .stroke(.gradientTop, lineWidth: 4)
                }
            }
            .accentColor(.gradientBottom) // color of user location
            .onAppear() {
                viewModel.checkLocEnabled()
            }
            // declare safe area for bottom elemets
            .safeAreaInset(edge: .bottom) {
                VStack {
                    // if a map item is selected
                    if let selectedResult {
                        withAnimation(.easeInOut(duration: 5)) {
                            ItemInfoView(selectedResult: selectedResult, route: route)
                                .frame(height: 128)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding([.top, .horizontal])
                        }
                    }
                    // bottom buttons and slider
                    BottomButtons(searchResults: $searchResults, buttonClicked: $buttonClicked, searchingRegion: MKCoordinateRegion(
                        center: viewModel.region.center,
                        latitudinalMeters: CLLocationDistance(5),
                        longitudinalMeters: CLLocationDistance(5)
                    ))
                    // slider to get desired radius
                    Slider(
                        value: $radius,
                        in: 0...20,
                        step: 0.1,
                        onEditingChanged: { editing in
                            isEditing = editing
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    // randomize button
                    if randomize {
                        Button {
                            Task { // async task
                                randomize = false
                                chooseRestaurant()
                                withAnimation {
                                    newRandom.toggle()
                                }
                            }
                        } label : {
                            Label("Choose For Me!", systemImage: "")
                        }
                        .labelStyle(.titleOnly)
                    }
                    
                    if newRandom {
                        Button {
                            Task {
                                chooseNewRestaurant()
                            }
                        } label : {
                            Label("Choose Again!", systemImage: "")
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
                route = nil // clear any route which is leftover
                checkChange()
            }
            // when item selected changes (or is selected) get directions to said item
            .onChange(of: selectedResult) {
                if selectedResult == nil {
                    newRandom = false
                    
                    if searchResults.count == 1 {
                        searchResults.removeAll()
                    }
                }
                // getting directions asyc as to not slow other ui elements
                Task {
                    getDirections()
                }
                
            }
        }
    }
}
