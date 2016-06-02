//
//  LevelStats.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import ObjectMapper

struct LevelProgress: Progress, Mappable {
    
    var rank: Int?
    var locked: Bool!
    var level: Level!
    
    private(set) var levelId: Int!
    private(set) var maxWinsCountInRow: Int!
    private(set) var currentWinsCountInRow: Int!
    private(set) var winsCount: Int!
    private(set) var lossesCount: Int!
    private(set) var wonChipsCount: Int64!
    private(set) var lostChipsCount: Int64!
    
    var chipsCount: Int64 {
        return wonChipsCount - lostChipsCount
    }
    
    var leaderboardID: String {
        return level.leaderboardID
    }
    
    var identifier: String {
        return String(levelId)
    }

    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        let transformOfInt64 = TransformOf<Int64, NSNumber>(fromJSON: { $0?.longLongValue }, toJSON: { $0.map { NSNumber(longLong: $0) } })
        
        levelId <- map["level_id"]
        locked <- map["locked"]
        maxWinsCountInRow <- map["max_wins_count_in_row"]
        currentWinsCountInRow <- map["wins_count_in_row"]
        winsCount <- map["wins_count"]
        lossesCount <- map["losses_count"]
        wonChipsCount <- (map["won_chips_count"], transformOfInt64)
        lostChipsCount <- (map["lost_chips_count"], transformOfInt64)
        rank <- map["rank"]
    }
}

extension LevelProgress {
    
    mutating func trackWinWithChipsCount(chipsCount: Int64) {
        maxWinsCountInRow = max(currentWinsCountInRow + 1, maxWinsCountInRow)
        currentWinsCountInRow! += 1
        winsCount! += 1
        wonChipsCount! += chipsCount
    }
    
    mutating func trackLostWithChipsCount(chipsCount: Int64) {
        currentWinsCountInRow = 0
        lossesCount! += 1
        lostChipsCount! += chipsCount
    }
}
