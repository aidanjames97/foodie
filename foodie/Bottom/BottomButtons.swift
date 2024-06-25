//
//  BottomButtoms.swift
//  foodie
//
//  Created by Aidan James on 2024-06-20.
//

import SwiftUI
import MapKit

struct BottomButtons: View {
    @StateObject private var viewModel = MapPageModel() // model for location
    @Binding var searchResults: [MKMapItem] // results from search
    @Binding var buttonClicked: Bool
    var searchingRegion: MKCoordinateRegion
    
    // searching for restaurants in area
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = searchingRegion
        // search for restaurants
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? [] // restaurants or empty array
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    search(for: "burgers")
                    withAnimation() {
                        buttonClicked = true
                    }
                } label : {
                    Label("🍔", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "pizza")
                    withAnimation {
                        buttonClicked = true
                    }
                } label : {
                    Label("🍕", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "tacos")
                    withAnimation {
                        buttonClicked = true
                    }
                } label : {
                    Label("🌮", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "food")
                    withAnimation {
                        buttonClicked = true
                    }
                } label : {
                    Label("❓", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "bars")
                    withAnimation {
                        buttonClicked = true
                    }
                } label : {
                    Label("🍻", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "sushi")
                    withAnimation {
                        buttonClicked = true
                    }
                } label : {
                    Label("🍣", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "pasta")
                    withAnimation {
                        buttonClicked = true
                    }
                } label : {
                    Label("🍝", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Spacer()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 10)
        .padding(.horizontal, 10)
    }
}
