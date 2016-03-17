//
//  PlayerProgress.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct PlayerProgress: Progress {
    
    let maxNumberOfWinsInRow: Int!
    let numberOfWins: Int!
    let numberOfLosses: Int!
    let chipsCount: Int64!
    let leaderboardID: String
    let rank: Int?
    
    var title: String {
        return NSLocalizedString("Overall", comment: "")
    }
}
