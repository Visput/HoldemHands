//
//  Player.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct Player {
    
    var levelProgressItems: [GameLevelProgress]
    var score: Int
    
    init() {
        levelProgressItems = [GameLevelProgress]()
        score = 0
    }
}
