//
//  GameLevelStats.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct GameLevelProgress {
    
    let level: GameLevel
    let locked: Bool
    let notifiedToUnlock: Bool
    let maxNumberOfWinsInRow: Int
    let currentNumberOfWinsInRow: Int
    let numberOfWins: Int
    let numberOfLosses: Int
    let chipsCount: Double
    
    init(level: GameLevel) {
        self.level = level
        self.locked = true
        self.notifiedToUnlock = false
        self.maxNumberOfWinsInRow = 0
        self.currentNumberOfWinsInRow = 0
        self.numberOfWins = 0
        self.numberOfLosses = 0
        self.chipsCount = 0
    }
    
    init(level: GameLevel,
        locked: Bool,
        notifiedToUnlock: Bool,
        maxNumberOfWinsInRow: Int,
        currentNumberOfWinsInRow: Int,
        numberOfWins: Int,
        numberOfLosses: Int,
        chipsCount: Double) {
        
            self.level = level
            self.locked = locked
            self.notifiedToUnlock = notifiedToUnlock
            self.maxNumberOfWinsInRow = maxNumberOfWinsInRow
            self.currentNumberOfWinsInRow = currentNumberOfWinsInRow
            self.numberOfWins = numberOfWins
            self.numberOfLosses = numberOfLosses
            self.chipsCount = chipsCount
    }
}

extension GameLevelProgress {
    
    func levelProgressByIncrementingNumberOfWins(chipsWon chipsWon: Double) -> GameLevelProgress {
        return self.dynamicType.init(level: level,
            locked: locked,
            notifiedToUnlock: notifiedToUnlock,
            maxNumberOfWinsInRow: max(currentNumberOfWinsInRow + 1, maxNumberOfWinsInRow),
            currentNumberOfWinsInRow: currentNumberOfWinsInRow + 1,
            numberOfWins: numberOfWins + 1,
            numberOfLosses: numberOfLosses,
            chipsCount: chipsCount + chipsWon)
    }
    
    func levelProgressByIncrementingNumberOfLosses(chipsLost chipsLost: Double) -> GameLevelProgress {
        return self.dynamicType.init(level: level,
            locked: locked,
            notifiedToUnlock: notifiedToUnlock,
            maxNumberOfWinsInRow: maxNumberOfWinsInRow,
            currentNumberOfWinsInRow: 0,
            numberOfWins: numberOfWins,
            numberOfLosses: numberOfLosses + 1,
            chipsCount: chipsCount - chipsLost)
    }
    
    func levelProgressBySettingNotifiedToUnlock() -> GameLevelProgress {
        return self.dynamicType.init(level: level,
            locked: locked,
            notifiedToUnlock: true,
            maxNumberOfWinsInRow: maxNumberOfWinsInRow,
            currentNumberOfWinsInRow: currentNumberOfWinsInRow,
            numberOfWins: numberOfWins,
            numberOfLosses: numberOfLosses,
            chipsCount: chipsCount)
    }
    
    func levelProgressBySettingUnlocked() -> GameLevelProgress {
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
