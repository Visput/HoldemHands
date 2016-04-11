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
    private(set) var timestamp: Double!
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        let transformOfInt64 = TransformOf<Int64, NSNumber>(fromJSON: { $0?.longLongValue }, toJSON: { $0.map { NSNumber(longLong: $0) } })
        
        levelProgressItems <- map["level_progress_items"]
        chipsCount <- (map["chips_count"], transformOfInt64)
        rank <- map["rank"]
        timestamp <- map["timestamp"]
    }
    
    mutating func generateTimestamp() {
        timestamp = NSDate().timeIntervalSince1970
    }
}
