//
//  Player.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct Player {
    
    var levelProgressItems: [LevelProgress]
    var chipsCount: Double
    
    init() {
        levelProgressItems = [LevelProgress]()
        chipsCount = 0
    }
}
