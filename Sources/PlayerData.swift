//
//  PlayerData.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import ObjectMapper

struct PlayerData: Mappable {
    
    var levelProgressItems: [LevelProgress]!
    var chipsCount: Int64!
    
    init() {
        levelProgressItems = [LevelProgress]()
        chipsCount = 0
    }
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        levelProgressItems <- map["levelProgressItems"]
        chipsCount <- map["chipsCount"]
    }
}
