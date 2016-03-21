//
//  PlayerProgress.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct PlayerProgress: Progress {
    
    let maxWinsCountInRow: Int!
    let winsCount: Int!
    let lossesCount: Int!
    let chipsCount: Int64
    let leaderboardID: String
    let rank: Int?
    
    var title: String {
        return NSLocalizedString("Overall", comment: "")
    }
}
