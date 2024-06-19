//
//  Landing.swift
//  foodie
//
//  Created by Aidan James on 2024-06-18.
//

import SwiftUI

struct Landing: View {
    var body: some View {
    HStack {
        Spacer()
        VStack {
            Spacer()
            // title
            Text("Foodie")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
        Spacer()
    }
    .foregroundStyle(.white)
    }
}

#Preview {
    Landing()
}
