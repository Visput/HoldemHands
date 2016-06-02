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
    private var player: GKLocalPlayer!

    var authenticated: Bool {
        return player.authenticated
    }
    
    private var notifier: PlayerManagerObserverNotifier!
    private var synchronizer: PlayerDataSynchronizer!
    private var keychainStorage: PlayerDataKeychainStorage!
    private var cloudStorage: PlayerDataCloudStorage!
    
    init(navigationManager: NavigationManager) {
        player = GKLocalPlayer.localPlayer()
        keychainStorage = PlayerDataKeychainStorage(player: player)
        
        notifier = PlayerManagerObserverNotifier(playerManager: self)
        cloudStorage = PlayerDataCloudStorage(player: player,
                                              navigationManager: navigationManager,
                                              didAutoLoadPlayerDataHandler: { [unowned self] playerData in
                                                self.handleLoadedPlayerData(playerData)
        })
        synchronizer = PlayerDataSynchronizer(loadHandler: { [unowned self] in
            self.loadPlayerData()
        }, saveHandler: { [unowned self] in
                self.savePlayerData()
        })
        
        loadPlayerData()
    }
}

extension PlayerManager {
    
    func trackNewWinInLevel(level: Level) {
        updateLastPlayedLevel(level)
        
        let oldChipsCount = playerData.chipsCount
        let chipsMultiplier = playerData.chipsMultiplierForLevel(level)
        let chipsWon = level.chipsPerWin * chipsMultiplier
        playerData.chipsCount! += chipsWon
        
        let progressIndex = playerData.progressForLevel(level).index
        playerData.levelProgressItems[progressIndex].trackWinWithChipsCount(chipsWon)
        
        notifier.notifyObserversDidUpdateChipsCount(playerData.chipsCount, oldChipsCount: oldChipsCount, chipsMultiplier: chipsMultiplier)
        
        updateLockStateForLevels()
    }
    
    func trackNewLossInLevel(level: Level) {
        updateLastPlayedLevel(level)
        
        let oldChipsCount = playerData.chipsCount
        let chipsLost = level.chipsPerWin
        // Total chips count can not be less than zero.
        playerData.chipsCount = max(Int64(0), playerData.chipsCount - chipsLost)
        
        let progressIndex = playerData.progressForLevel(level).index
        playerData.levelProgressItems[progressIndex].trackLostWithChipsCount(chipsLost)
        
        guard playerData.chipsCount != oldChipsCount else { return }
        notifier.notifyObserversDidUpdateChipsCount(playerData.chipsCount, oldChipsCount: oldChipsCount, chipsMultiplier: 1)
    }
    
    func trackFinishPlayLevel(level: Level) {
        savePlayerData()
    }
    
    func loadProgressItemsIncludingRank(completionHandler: (progressItems: [Progress]?, error: NSError?) -> Void) {
        guard player.authenticated else {
            completionHandler(progressItems: playerData.progressItems(), error: nil)
            return
        }
        
        var leaderboards = [GKLeaderboard]()
        for progress in playerData.progressItems() {
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
                    completionHandler(progressItems: self.playerData.progressItems(), error: nil)
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
}

extension PlayerManager {
    
    private func reportScores() {
        guard player.authenticated else { return }
        
        var overallScore: Int64 = 0
        
        for progress in playerData.levelProgressItems {
            guard progress.handsCount > 0 else { continue }
            
            let score = GKScore()
            score.value = playerData.scoreForLevelProgress(progress)
            overallScore += score.value
            score.leaderboardIdentifier = progress.level.leaderboardID
            
            GKScore.reportScores([score], withCompletionHandler: { error in
                Analytics.error(error)
            })
        }
        
        guard playerData.playerProgress().handsCount > 0 else { return }
        
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
                    notifier.notifyObserversDidUnlockLevel(levelProgress)
                    didUnlock = true
                }
            }
        }
        if didUnlock {
            savePlayerData()
        }
    }
    
    private func updateLastPlayedLevel(level: Level) {
        if playerData.lastPlayedLevelID != level.identifier {
            playerData.lastPlayedLevelID = level.identifier
            notifier.notifyObserversDidUpdateLastPlayedLavel(playerData.lastPlayedLevel()!)
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
        notifier.notifyObserversDidLoadPlayerData(playerData)
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
