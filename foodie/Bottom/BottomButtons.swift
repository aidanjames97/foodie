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
            Text("What do you feel like?")
                .font(.title3)
                .bold()
                .foregroundStyle(.tint)
            HStack {
                Spacer()
                Button {
                    search(for: "burgers")
                } label : {
                    Label("🍔", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "pizza")
                } label : {
                    Label("🍕", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "tacos")
                } label : {
                    Label("🌮", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "food")
                } label : {
                    Label("❓", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Button {
                    search(for: "bars")
                } label : {
                    Label("🍻", systemImage: "")
                }
                .labelStyle(.titleOnly)
                Spacer()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 5)
    }
}
