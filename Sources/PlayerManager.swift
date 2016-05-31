//
//  PlayerManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit
import GameKit
import ObjectMapper

final class PlayerManager {
    
    enum ErrorCode: Int {
        case FailedToLoadRankFromGameCenter
    }
    
    let errorDomain = "PlayerManagerErrorDomain"
    
    let observers = ObserverSet<PlayerManagerObserving>()
    
    private(set) var playerData: PlayerData!
    private(set) var player: GKLocalPlayer!

    private(set) var playerDataSynchronizer: PlayerDataSynchronizer!
    private(set) var keychainStorage: PlayerDataKeychainStorage!
    private(set) var cloudStorage: PlayerDataCloudStorage!
    
    var authenticated: Bool {
        return player.authenticated
    }
    
    init(navigationManager: NavigationManager) {
        player = GKLocalPlayer.localPlayer()
        keychainStorage = PlayerDataKeychainStorage(player: player)
        cloudStorage = PlayerDataCloudStorage(player: player,
                                              navigationManager: navigationManager,
                                              didAutoLoadPlayerDataHandler: { [unowned self] playerData in
                                                self.handleLoadedPlayerData(playerData)
        })
        playerDataSynchronizer = PlayerDataSynchronizer(loadHandler: { [unowned self] in
            self.loadPlayerData()
        }, saveHandler: { [unowned self] in
            self.savePlayerData()
        })
        
        loadPlayerData()
    }
    
    func isLockedLevel(level: Level) -> Bool {
        let progress = progressItemForLevel(level).progress
        return progress.locked
    }
    
    func trackNewWinInLevel(level: Level) {
        playerData.lastPlayedLevelID = level.identifier
        
        let oldChipsCount = playerData.chipsCount
        let chipsMultiplier = chipsMultiplierForLevel(level)
        let chipsWon = level.chipsPerWin * chipsMultiplier
        playerData.chipsCount! += chipsWon
        
        let progressItem = progressItemForLevel(level)
        playerData.levelProgressItems[progressItem.index].trackWinWithChipsCount(chipsWon)
        
        notifyObserversDidUpdateChipsCount(playerData.chipsCount, oldChipsCount: oldChipsCount, chipsMultiplier: chipsMultiplier)
        
        updateLockStateForLevels()
    }
    
    func trackNewLossInLevel(level: Level) {
        playerData.lastPlayedLevelID = level.identifier
        
        let oldChipsCount = playerData.chipsCount
        let chipsLost = level.chipsPerWin
        // Total chips count can not be less than zero.
        playerData.chipsCount = max(Int64(0), playerData.chipsCount - chipsLost)

        let progressItem = progressItemForLevel(level)
        playerData.levelProgressItems[progressItem.index].trackLostWithChipsCount(chipsLost)
        
        guard playerData.chipsCount != oldChipsCount else { return }
        notifyObserversDidUpdateChipsCount(playerData.chipsCount, oldChipsCount: oldChipsCount, chipsMultiplier: 1)
    }
    
    func trackFinishPlayLevel(level: Level) {
        savePlayerData()
    }
    
    func chipsMultiplierForLevel(level: Level) -> Int64 {
        let progressItem = progressItemForLevel(level)
        return Int64(1 + progressItem.progress.currentWinsCountInRow / level.winsInRowToDoubleChips)
    }
    
    func chipsToUnlockLevel(level: Level) -> Int64 {
        return level.chipsToUnlock - playerData.chipsCount
    }
    
    func playerProgress() -> PlayerProgress {
        var maxWinsCountInRow = 0
        var winsCount = 0
        var lossesCount = 0
        
        for levelProgress in playerData.levelProgressItems {
            maxWinsCountInRow = max(maxWinsCountInRow, levelProgress.maxWinsCountInRow)
            winsCount += levelProgress.winsCount
            lossesCount += levelProgress.lossesCount
        }
        
        return PlayerProgress(maxWinsCountInRow: maxWinsCountInRow,
            winsCount: winsCount,
            lossesCount: lossesCount,
            chipsCount: playerData.chipsCount,
            leaderboardID: playerData.overallLeaderboardID,
            rank: playerData.rank)
    }
    
    func progressItems() -> [Progress] {
        var progressItems: [Progress] = [playerProgress()]
        for levelProgressItem in playerData.levelProgressItems {
            progressItems.append(levelProgressItem)
        }
        return progressItems
    }
    
    func loadProgressItemsIncludingRank(completionHandler: (progressItems: [Progress]?, error: NSError?) -> Void) {
        guard player.authenticated else {
            completionHandler(progressItems: progressItems(), error: nil)
            return
        }
        
        var leaderboards = [GKLeaderboard]()
        for progress in progressItems() {
            let leaderboard = GKLeaderboard(players: [player])
            leaderboard.identifier = progress.leaderboardID
            leaderboards.append(leaderboard)
        }
        
        func handleProcessedLeaderboard(leaderboard: GKLeaderboard?, error: NSError?) {
            guard leaderboards.count != 0 else { return }
            if error != nil {
                // Handle only first error.
                leaderboards.removeAll()
                Analytics.error(error)
                completionHandler(progressItems: nil, error: error)
            } else {
                leaderboards.removeAtIndex(leaderboards.indexOf(leaderboard!)!)
                if leaderboards.count == 0 {
                    completionHandler(progressItems: self.progressItems(), error: nil)
                }
            }
        }
        
        for leaderboard in leaderboards {
            leaderboard.loadScoresWithCompletionHandler({ _, error in
                guard error == nil else {
                    let resultError = NSError(domain: self.errorDomain,
                        code: ErrorCode.FailedToLoadRankFromGameCenter.rawValue,
                        userInfo: [NSUnderlyingErrorKey: error!])
                    handleProcessedLeaderboard(nil, error: resultError)
                    return
                }
                
                if leaderboard.identifier == self.playerData.overallLeaderboardID {
                    self.playerData.rank = leaderboard.localPlayerScore?.rank
                    handleProcessedLeaderboard(leaderboard, error: nil)
                    
                } else {
                    for (index, progress) in self.playerData.levelProgressItems.enumerate() {
                        if progress.leaderboardID == leaderboard.identifier {
                            self.playerData.levelProgressItems[index].rank = leaderboard.localPlayerScore?.rank
                            handleProcessedLeaderboard(leaderboard, error: nil)
                            break
                        }
                    }
                }
            })
        }
    }
    
    func progressItemForLevel(level: Level) -> (index: Int, progress: LevelProgress) {
        var progressItem: (Int, LevelProgress)! = nil
        for (index, progress) in playerData.levelProgressItems.enumerate() {
            if progress.level == level {
                progressItem = (index, progress)
                break
            }
        }
        
        return progressItem
    }
    
    private func scoreForLevelProgress(progress: LevelProgress) -> Int64 {
        let decimalScore = pow(Double(progress.handsCount), 0.7) *
            Double(progress.level.chipsPerWin) *
            Double(progress.wonChipsCount + progress.level.chipsPerWin) /
            Double(progress.wonChipsCount + progress.lostChipsCount + progress.level.chipsPerWin)
        
        let score = Int64(round(decimalScore))
        
        return score
    }
    
    private func reportScores() {
        guard player.authenticated else { return }
        
        var overallScore: Int64 = 0
        
        for progress in playerData.levelProgressItems {
            guard progress.handsCount > 0 else { continue }
            
            let score = GKScore()
            score.value = scoreForLevelProgress(progress)
            overallScore += score.value
            score.leaderboardIdentifier = progress.level.leaderboardID
            
            GKScore.reportScores([score], withCompletionHandler: { error in
                Analytics.error(error)
            })
        }
        
        guard playerProgress().handsCount > 0 else { return }
        
        let score = GKScore()
        score.value = overallScore
        score.leaderboardIdentifier = playerData.overallLeaderboardID
        
        GKScore.reportScores([score], withCompletionHandler: { error in
            Analytics.error(error)
        })   
    }
    
    private func updateLockStateForLevels() {
        var didUnlock = false
        for index in (playerData.levelProgressItems.count - 1).stride(through: 0, by: -1) {
            let levelProgress = playerData.levelProgressItems[index]
            if levelProgress.locked! && levelProgress.level.chipsToUnlock <= playerData.chipsCount {
                playerData.levelProgressItems[index].locked = false
                
                if !didUnlock {
                    notifyObserversDidUnlockLevel(levelProgress)
                    didUnlock = true
                }
            }
        }
        if didUnlock {
            savePlayerData()
        }
    }
}

extension PlayerManager {
    
    private func loadPlayerData() {
        if playerData == nil {
            let playerData = keychainStorage.loadPlayerData(useLastPlayerIfNeeded: true)
            handleLoadedPlayerData(playerData)
        } else {
            cloudStorage.loadPlayerDataWithCompletionHandler { [unowned self] playerData in
                if let playerData = playerData {
                    self.handleLoadedPlayerData(playerData)
                } else {
                    let playerData = self.keychainStorage.loadPlayerData(useLastPlayerIfNeeded: false)
                    self.handleLoadedPlayerData(playerData)
                }
            }
        }
    }
    
    private func handleLoadedPlayerData(newPlayerData: PlayerData) {
        if playerData == nil || // Data hasn't initialized yet.
            playerData.timestamp < newPlayerData.timestamp || // New data timestamp is newer than current data timestamp.
            (player.authenticated && player.playerID != keychainStorage.lastSavedPlayerId) || // New player signed in.
            (!player.authenticated && keychainStorage.lastSavedPlayerId != keychainStorage.guestPlayerId) { // Player signed out.
            
            playerData = newPlayerData
            updateLockStateForLevels()
        }
        
        // Notify observers even if `self.playerData` not updated.
        // because player authentication status can be changed (this is part of player data).
        notifyObserversDidLoadPlayerData()
    }
    
    private func savePlayerData() {
        playerData.generateTimestamp()
        keychainStorage.savePlayerData(playerData)
        cloudStorage.savePlayerData(playerData)
        
        if player.authenticated {
            reportScores()
        }
    }
    
    private func deletePlayerData() {
        keychainStorage.deletePlayerData()
        cloudStorage.deletePlayerData()
    }
}

extension PlayerManager {
    
    private func notifyObserversDidUnlockLevel(levelProgress: LevelProgress) {
        for observer in observers {
            observer.playerManager(self, didUnlockLevel: levelProgress)
        }
    }
    
    private func notifyObserversDidLoadPlayerData() {
        for observer in observers {
            observer.playerManager(self, didLoadPlayerData: playerData)
        }
    }
    
    private func notifyObserversDidUpdateChipsCount(newChipsCount: Int64, oldChipsCount: Int64, chipsMultiplier: Int64) {
        for observer in observers {
            observer.playerManager(self, didUpdateChipsCount: newChipsCount, oldChipsCount: oldChipsCount, chipsMultiplier: chipsMultiplier)
        }
    }
}
