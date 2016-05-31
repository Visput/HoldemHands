//
//  PlayerData+Utils.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/31/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

extension PlayerData {
    
    func isLockedLevel(level: Level) -> Bool {
        let progress = progressForLevel(level).instance
        return progress.locked
    }
    
    func chipsMultiplierForLevel(level: Level) -> Int64 {
        let progress = progressForLevel(level).instance
        return Int64(1 + progress.currentWinsCountInRow / level.winsInRowToDoubleChips)
    }
    
    func chipsToUnlockLevel(level: Level) -> Int64 {
        return level.chipsToUnlock - chipsCount
    }
}

extension PlayerData {
    
    func progressItems() -> [Progress] {
        var progressItems: [Progress] = [playerProgress()]
        for levelProgress in levelProgressItems {
            progressItems.append(levelProgress)
        }
        return progressItems
    }
    
    func playerProgress() -> PlayerProgress {
        var maxWinsCountInRow = 0
        var winsCount = 0
        var lossesCount = 0
        
        for levelProgress in levelProgressItems {
            maxWinsCountInRow = max(maxWinsCountInRow, levelProgress.maxWinsCountInRow)
            winsCount += levelProgress.winsCount
            lossesCount += levelProgress.lossesCount
        }
        
        return PlayerProgress(maxWinsCountInRow: maxWinsCountInRow,
                              winsCount: winsCount,
                              lossesCount: lossesCount,
                              chipsCount: chipsCount,
                              leaderboardID: overallLeaderboardID,
                              rank: rank)
    }
    
    func progressForLevel(level: Level) -> (index: Int, instance: LevelProgress) {
        var progress: (Int, LevelProgress)! = nil
        for (index, progressInstance) in levelProgressItems.enumerate() {
            if progressInstance.level == level {
                progress = (index, progressInstance)
                break
            }
        }
        
        return progress
    }
}

extension PlayerData {
    
    func scoreForLevelProgress(progress: LevelProgress) -> Int64 {
        let decimalScore = pow(Double(progress.handsCount), 0.7) *
            Double(progress.level.chipsPerWin) *
            Double(progress.wonChipsCount + progress.level.chipsPerWin) /
            Double(progress.wonChipsCount + progress.lostChipsCount + progress.level.chipsPerWin)
        
        let score = Int64(round(decimalScore))
        
        return score
    }
}
