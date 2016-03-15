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
    
    private(set) var level: Level!
    private(set) var locked: Bool!
    private(set) var notifiedToUnlock: Bool!
    private(set) var maxNumberOfWinsInRow: Int!
    private(set) var currentNumberOfWinsInRow: Int!
    private(set) var numberOfWins: Int!
    private(set) var numberOfLosses: Int!
    private(set) var chipsCount: Int64!
    
    var title: String? {
        return level.name
    }
    
    init(level: Level,
        locked: Bool,
        notifiedToUnlock: Bool,
        maxNumberOfWinsInRow: Int,
        currentNumberOfWinsInRow: Int,
        numberOfWins: Int,
        numberOfLosses: Int,
        chipsCount: Int64) {
        
            self.level = level
            self.locked = locked
            self.notifiedToUnlock = notifiedToUnlock
            self.maxNumberOfWinsInRow = maxNumberOfWinsInRow
            self.currentNumberOfWinsInRow = currentNumberOfWinsInRow
            self.numberOfWins = numberOfWins
            self.numberOfLosses = numberOfLosses
            self.chipsCount = chipsCount
    }
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        let transformOfInt64 = TransformOf<Int64, NSNumber>(fromJSON: { $0?.longLongValue }, toJSON: { $0.map { NSNumber(longLong: $0) } })
        
        level <- map["level"]
        locked <- map["locked"]
        notifiedToUnlock <- map["notified_to_unlock"]
        maxNumberOfWinsInRow <- map["max_number_of_wins_in_row"]
        currentNumberOfWinsInRow <- map["current_number_of_wins_in_row"]
        numberOfWins <- map["number_of_wins"]
        numberOfLosses <- map["number_of_losses"]
        chipsCount <- (map["chips_count"], transformOfInt64)
    }
}

extension LevelProgress {
    
    func levelProgressByIncrementingNumberOfWins(chipsWon chipsWon: Int64) -> LevelProgress {
        return self.dynamicType.init(level: level,
            locked: locked,
            notifiedToUnlock: notifiedToUnlock,
            maxNumberOfWinsInRow: max(currentNumberOfWinsInRow + 1, maxNumberOfWinsInRow),
            currentNumberOfWinsInRow: currentNumberOfWinsInRow + 1,
            numberOfWins: numberOfWins + 1,
            numberOfLosses: numberOfLosses,
            chipsCount: chipsCount + chipsWon)
    }
    
    func levelProgressByIncrementingNumberOfLosses(chipsLost chipsLost: Int64) -> LevelProgress {
        return self.dynamicType.init(level: level,
            locked: locked,
            notifiedToUnlock: notifiedToUnlock,
            maxNumberOfWinsInRow: maxNumberOfWinsInRow,
            currentNumberOfWinsInRow: 0,
            numberOfWins: numberOfWins,
            numberOfLosses: numberOfLosses + 1,
            chipsCount: chipsCount - chipsLost)
    }
    
    func levelProgressBySettingNotifiedToUnlock() -> LevelProgress {
        return self.dynamicType.init(level: level,
            locked: locked,
            notifiedToUnlock: true,
            maxNumberOfWinsInRow: maxNumberOfWinsInRow,
            currentNumberOfWinsInRow: currentNumberOfWinsInRow,
            numberOfWins: numberOfWins,
            numberOfLosses: numberOfLosses,
            chipsCount: chipsCount)
    }
    
    func levelProgressBySettingUnlocked() -> LevelProgress {
        return self.dynamicType.init(level: level,
            locked: false,
            notifiedToUnlock: notifiedToUnlock,
            maxNumberOfWinsInRow: maxNumberOfWinsInRow,
            currentNumberOfWinsInRow: currentNumberOfWinsInRow,
            numberOfWins: numberOfWins,
            numberOfLosses: numberOfLosses,
            chipsCount: chipsCount)
    }
}
