//
//  Item.swift
//  HomeCycle
//
//  Created by HYUNJAE on 4/16/26.
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
