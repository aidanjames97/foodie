//
//  Item.swift
//  foodie
//
//  Created by Aidan James on 2024-06-17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
