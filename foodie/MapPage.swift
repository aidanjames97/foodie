//
//  MapPage.swift
//  foodie
//
//  Created by Aidan James on 2024-06-19.
//

import SwiftUI
import MapKit

struct MapPage: View {
    var body: some View {
        VStack {
            Map() {

            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    VStack {
                        Text("What do you feel like?")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.tint)
                        
                        HStack {
                            Button {
                                print("want buger")
                            } label : {
                                Label("🍔", systemImage: "")
                            }
                            .labelStyle(.titleOnly)
                            Button {
                                print("want za")
                            } label : {
                                Label("🍕", systemImage: "")
                            }
                            .labelStyle(.titleOnly)
                            Button {
                                print("want taco")
                            } label : {
                                Label("🌮", systemImage: "")
                            }
                            .labelStyle(.titleOnly)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                }
                .background(.ultraThinMaterial)
            }
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapScaleView()
            }
        }
    }
}

#Preview {
    MapPage()
}
