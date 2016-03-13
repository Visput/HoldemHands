//
//  PlayerProgress.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct PlayerProgress: Progress {
    
    let maxNumberOfWinsInRow: Int
    let numberOfWins: Int
    let numberOfLosses: Int
    let chipsCount: Double
    
    var title: String? {
        return nil
    }
}
