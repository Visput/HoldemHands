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
    
    private(set) var levelID: Int!
    private(set) var level: Level!
    private(set) var locked: Bool!
    private(set) var maxWinsCountInRow: Int!
    private(set) var currentWinsCountInRow: Int!
    private(set) var winsCount: Int!
    private(set) var lossesCount: Int!
    private(set) var wonChipsCount: Int64!
    private(set) var lostChipsCount: Int64!
    private(set) var rank: Int?
    
    var chipsCount: Int64 {
        return wonChipsCount - lostChipsCount
    }
    
    var title: String {
        return level.name
    }
    
    var leaderboardID: String {
        return level.leaderboardID
    }
    
    init(levelID: Int,
        level: Level,
        locked: Bool,
        maxWinsCountInRow: Int,
        currentWinsCountInRow: Int,
        winsCount: Int,
        lossesCount: Int,
        wonChipsCount: Int64,
        lostChipsCount: Int64,
        rank: Int?) {
            
            self.levelID = levelID
            self.level = level
            self.locked = locked
            self.maxWinsCountInRow = maxWinsCountInRow
            self.currentWinsCountInRow = currentWinsCountInRow
            self.winsCount = winsCount
            self.lossesCount = lossesCount
            self.wonChipsCount = wonChipsCount
            self.lostChipsCount = lostChipsCount
            self.rank = rank
    }
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        let transformOfInt64 = TransformOf<Int64, NSNumber>(fromJSON: { $0?.longLongValue }, toJSON: { $0.map { NSNumber(longLong: $0) } })
        
        levelID <- map["level_id"]
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
    
    func levelProgressBySettingLevel(level: Level) -> LevelProgress {
        return self.dynamicType.init(levelID: levelID,
            level: level,
            locked: locked,
            maxWinsCountInRow: maxWinsCountInRow,
            currentWinsCountInRow: currentWinsCountInRow,
            winsCount: winsCount,
            lossesCount: lossesCount,
            wonChipsCount: wonChipsCount,
            lostChipsCount: lostChipsCount,
            rank: rank)
    }
    
    func levelProgressByIncrementingWinsCount(chipsWon chipsWon: Int64) -> LevelProgress {
        return self.dynamicType.init(levelID: levelID,
            level: level,
            locked: locked,
            maxWinsCountInRow: max(currentWinsCountInRow + 1, maxWinsCountInRow),
            currentWinsCountInRow: currentWinsCountInRow + 1,
            winsCount: winsCount + 1,
            lossesCount: lossesCount,
            wonChipsCount: wonChipsCount + chipsWon,
            lostChipsCount: lostChipsCount,
            rank: rank)
    }
    
    func levelProgressByIncrementingLossesCount(chipsLost chipsLost: Int64) -> LevelProgress {
        return self.dynamicType.init(levelID: levelID,
            level: level,
            locked: locked,
            maxWinsCountInRow: maxWinsCountInRow,
            currentWinsCountInRow: 0,
            winsCount: winsCount,
            lossesCount: lossesCount + 1,
            wonChipsCount: wonChipsCount,
            lostChipsCount: lostChipsCount + chipsLost,
            rank: rank)
    }
    
    func levelProgressBySettingUnlocked() -> LevelProgress {
        return self.dynamicType.init(levelID: levelID,
            level: level,
            locked: false,
            maxWinsCountInRow: maxWinsCountInRow,
            currentWinsCountInRow: currentWinsCountInRow,
            winsCount: winsCount,
            lossesCount: lossesCount,
            wonChipsCount: wonChipsCount,
            lostChipsCount: lostChipsCount,
            rank: rank)
    }
    
    func levelProgressBySettingRank(rank: Int?) -> LevelProgress {
        return self.dynamicType.init(levelID: levelID,
            level: level,
            locked: locked,
            maxWinsCountInRow: maxWinsCountInRow,
            currentWinsCountInRow: currentWinsCountInRow,
            winsCount: winsCount,
            lossesCount: lossesCount,
            wonChipsCount: wonChipsCount,
            lostChipsCount: lostChipsCount,
            rank: rank)
    }
}
