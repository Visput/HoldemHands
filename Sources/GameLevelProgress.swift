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
    let maxNumberOfWinsInRow: Int
    let currentNumberOfWinsInRow: Int
    let numberOfWins: Int
    let numberOfLosses: Int
    
    init(level: GameLevel) {
        self.level = level
        self.maxNumberOfWinsInRow = 0
        self.currentNumberOfWinsInRow = 0
        self.numberOfWins = 0
        self.numberOfLosses = 0
    }
    
    init(level: GameLevel,
        maxNumberOfWinsInRow: Int,
        currentNumberOfWinsInRow: Int,
        numberOfWins: Int,
        numberOfLosses: Int) {
        
            self.level = level
            self.maxNumberOfWinsInRow = maxNumberOfWinsInRow
            self.currentNumberOfWinsInRow = currentNumberOfWinsInRow
            self.numberOfWins = numberOfWins
            self.numberOfLosses = numberOfLosses
    }
}

extension GameLevelProgress {
    
    func levelProgressByIncrementingNumberOfWins() -> GameLevelProgress {
        return self.dynamicType.init(level: level,
            maxNumberOfWinsInRow: max(currentNumberOfWinsInRow + 1, maxNumberOfWinsInRow),
            currentNumberOfWinsInRow: currentNumberOfWinsInRow + 1,
            numberOfWins: numberOfWins + 1,
            numberOfLosses: numberOfLosses)
    }
    
    func levelProgressByIncrementingNumberOfLosses() -> GameLevelProgress {
        return self.dynamicType.init(level: level,
            maxNumberOfWinsInRow: maxNumberOfWinsInRow,
            currentNumberOfWinsInRow: 0,
            numberOfWins: numberOfWins,
            numberOfLosses: numberOfLosses + 1)
    }
}
