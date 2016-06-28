//
//  Level.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import ObjectMapper

struct Level: Equatable, Mappable {
    
    private(set) var numberOfHands: Int!
    private(set) var chipsToUnlock: Int64!
    private(set) var chipsPerWin: Int64!
    private(set) var maxTimeChipsBonus: Int64!
    private(set) var chipsBonusTime: Int!
    private(set) var winsInRowToDoubleChips: Int!
    private(set) var name: String!
    private(set) var identifier: Int!
    private(set) var leaderboardID: String!
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        numberOfHands <- map["hands_count"]
        chipsToUnlock <- (map["chips_to_unlock"], Int64Transform())
        chipsPerWin <- (map["chips_per_win"], Int64Transform())
        maxTimeChipsBonus <- (map["max_time_chips_bonus"], Int64Transform())
        chipsBonusTime <- map["chips_bonus_time"]
        winsInRowToDoubleChips <- map["wins_in_row_to_double_chips"]
        name <- map["name"]
        identifier <- map["id"]
        leaderboardID <- map["leaderboard_id"]
    }
}

func == (lhs: Level, rhs: Level) -> Bool {
    return lhs.identifier == rhs.identifier
}
