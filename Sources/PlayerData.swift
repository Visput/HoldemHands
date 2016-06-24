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
    var overallLeaderboardID: String!
    var rank: Int?
    var lastPlayedLevelID: Int?
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        levelProgressItems <- map["level_progress_items"]
        chipsCount <- (map["chips_count"], Int64Transform())
        rank <- map["rank"]
        lastPlayedLevelID <- map["last_played_level_id"]
    }
}
