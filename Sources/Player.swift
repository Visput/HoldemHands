//
//  Player.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct Player {
    
    var levelProgressItems: [GameLevelProgress]
    var chipsCount: Int
    
    init() {
        levelProgressItems = [GameLevelProgress]()
        chipsCount = 0
    }
}
