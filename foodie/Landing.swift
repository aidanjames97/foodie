//
//  Landing.swift
//  foodie
//
//  Created by Aidan James on 2024-06-25.
//

import SwiftUI
import MapKit

// global
let gradientColors: [Color] = [
    .gradientTop,
    .gradientBottom
]

struct Landing: View {
    @Binding var locationAllowed: Bool
    @StateObject var viewModel: MapPageModel
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            VStack {
                Spacer()
                ZStack {
                    // title text
                    Image(.logo)
                        .resizable()
                        .frame(width: 300, height: 300)
                        .padding(.bottom, 100)
                    
                    Text("Know where to eat? If not, we can help!")
                        .bold()
                        .padding(.top, 10)
                    
                    Button {
                        viewModel.checkLocEnabled()
                        if viewModel.isEnabled() {
                            withAnimation {
                                locationAllowed = true
                            }
                        }
                    } label : {
                        Label("Explore!", systemImage: "")
                            .bold()
                            .font(.title3)
                    }
                    .padding(.top, 110)
                    .labelStyle(.titleOnly)
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            }
            .foregroundStyle(.white)
            Spacer()
        }
        .background(Gradient(colors: gradientColors))
    }
}
