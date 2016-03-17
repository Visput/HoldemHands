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
import KeychainSwift

final class PlayerManager {
    
    enum ErrorCode: Int {
        case PlayerNotAuthenticated
        case FailedToLoadRankFromGameCenter
    }
    
    let errorDomain = "PlayerManagerErrorDomain"
    
    let observers = ObserverSet<PlayerManagerObserving>()
    
    private(set) var playerData: PlayerData!
    private var player: GKLocalPlayer!

    private let navigationManager: NavigationManager
    private var autoSaveTimer: NSTimer?
    private let autoSaveTimerInterval = 60.0 // Secs.
    private let playerIdentifierKey = "PlayerIdentifier"
    private let keychain = KeychainSwift()
    
    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
        loadPlayer()
    }
    
    deinit {
        unregisterFromAppLifeCycleNotifications()
    }
    
    func isLockedLevel(level: Level) -> Bool {
        let progress = progressItemForLevel(level).progress
        return progress.locked
    }
    
    func canUnlockLevel(level: Level) -> Bool {
        return playerData.chipsCount >= level.chipsToUnlock
    }
    
    func unlockLevel(level: Level) {
        precondition(isLockedLevel(level))
        precondition(canUnlockLevel(level))
        
        playerData.chipsCount! -= level.chipsToUnlock
        let progressItem = progressItemForLevel(level)
        playerData.levelProgressItems[progressItem.index] = progressItem.progress.levelProgressBySettingUnlocked()
        
        savePlayer()
    }
    
    func trackNewWinInLevel(level: Level) {
        let chipsWon = level.chipsPerWin * chipsMultiplierForLevel(level)
        playerData.chipsCount! += chipsWon
        
        reportScore(playerData.chipsCount, toLeaderboardWithID: nil)
        
        let progressItem = progressItemForLevel(level)
        let newLevelProgress = progressItem.progress.levelProgressByIncrementingNumberOfWins(chipsWon: chipsWon)
        playerData.levelProgressItems[progressItem.index] = newLevelProgress
        
        guard progressItem.index < playerData.levelProgressItems.count - 1 else { return }
        var nextLevelProgress = playerData.levelProgressItems[progressItem.index + 1]
        if nextLevelProgress.locked! &&
            !nextLevelProgress.notifiedToUnlock! &&
            nextLevelProgress.level.chipsToUnlock <= playerData.chipsCount {
                
                nextLevelProgress = nextLevelProgress.levelProgressBySettingNotifiedToUnlock()
                playerData.levelProgressItems[progressItem.index + 1] = nextLevelProgress
                notifyObserversDidEarnChipsToUnlockLevel(nextLevelProgress)
        }
    }
    
    func trackNewLossInLevel(level: Level) {
        let chipsLost = level.chipsPerWin
        // Total chips count can not be less than zero.
        playerData.chipsCount = max(Int64(0), playerData.chipsCount - chipsLost)
        
        reportScore(playerData.chipsCount, toLeaderboardWithID: nil)
        
        let progressItem = progressItemForLevel(level)
        
        let newLevelProgress = progressItem.progress.levelProgressByIncrementingNumberOfLosses(chipsLost: chipsLost)
        playerData.levelProgressItems[progressItem.index] = newLevelProgress
    }
    
    func chipsMultiplierForLevel(level: Level) -> Int64 {
        let progressItem = progressItemForLevel(level)
        return Int64(pow(2, Double(progressItem.progress.currentNumberOfWinsInRow / level.winsInRowToDoubleChips)))
    }
    
    func playerProgress() -> PlayerProgress {
        var maxNumberOfWinsInRow = 0
        var numberOfWins = 0
        var numberOfLosses = 0
        
        for levelProgress in playerData.levelProgressItems {
            maxNumberOfWinsInRow = max(maxNumberOfWinsInRow, levelProgress.maxNumberOfWinsInRow)
            numberOfWins += levelProgress.numberOfWins
            numberOfLosses += levelProgress.numberOfLosses
        }
        
        return PlayerProgress(maxNumberOfWinsInRow: maxNumberOfWinsInRow,
            numberOfWins: numberOfWins,
            numberOfLosses: numberOfLosses,
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
            let error = NSError(domain: errorDomain, code: ErrorCode.PlayerNotAuthenticated.rawValue, userInfo: nil)
            Analytics.error(error)
            completionHandler(progressItems: nil, error: error)
            return
        }
        
        let leaderboard = GKLeaderboard(players: [player])
        leaderboard.loadScoresWithCompletionHandler({ scores, error in
            guard error == nil else {
                let resultError = NSError(domain: self.errorDomain,
                    code: ErrorCode.FailedToLoadRankFromGameCenter.rawValue,
                    userInfo: [NSUnderlyingErrorKey: error!])
                Analytics.error(resultError)
                completionHandler(progressItems: nil, error: resultError)
                return
            }
            
            for score in scores! {
                if score.leaderboardIdentifier == self.playerData.overallLeaderboardID {
                    self.playerData.rank = score.rank
                } else {
                    for (index, progress) in self.playerData.levelProgressItems.enumerate() {
                        if progress.leaderboardID == score.leaderboardIdentifier {
                            self.playerData.levelProgressItems[index] = progress.levelProgressBySettingRank(score.rank)
                            break
                        }
                    }
                }
            }
            
            completionHandler(progressItems: self.progressItems(), error: nil)
        })
        
    }
    
    private func progressItemForLevel(level: Level) -> (index: Int, progress: LevelProgress) {
        var progressItem: (Int, LevelProgress)! = nil
        for (index, progress) in playerData.levelProgressItems.enumerate() {
            if progress.level == level {
                progressItem = (index, progress)
                break
            }
        }
        
        return progressItem
    }
    
    private func reportScore(scoreValue: Int64, toLeaderboardWithID leaderboardID: String? = nil) {
        if player.authenticated {
            let score = GKScore()
            if leaderboardID != nil {
                score.leaderboardIdentifier = leaderboardID!
            }
            score.value = scoreValue
            GKScore.reportScores([score], withCompletionHandler: { error in
                Analytics.error(error!)
            })
        }
    }
}

extension PlayerManager {
    
    private func loadPlayer() {
        let oldPlayer: GKLocalPlayer? = player
        
        player = GKLocalPlayer.localPlayer()
        
        // Use last saved data while actual data is loading from GameCenter.
        loadPlayerDataFromLocalStorage(userLastPlayerIfNeeded: true)
        
        // Authenticate current user and load data from GameCenter.
        player.authenticateHandler = { [unowned self] (viewController: UIViewController?, error: NSError?) in
            
            // Register for notifications when `authenticateHandler` executed at least once.
            // This prevents from calling authentication twice when app is launched.
            self.registerForAppLifeCycleNotifications()
            
            if viewController != nil {
                // Present authentication screen.
                self.navigationManager.presentScreen(viewController!, animated: true)
            } else {
                Analytics.error(error!)
                
                if self.player.authenticated {
                    Analytics.userName(self.player.alias!)
                    Analytics.userID(self.player.playerID!)
                    
                    // Load GKSavedGame objects for authenticated player.
                    self.player.fetchSavedGamesWithCompletionHandler({ (savedGames: [GKSavedGame]?, error: NSError?) in
                        if error != nil {
                            Analytics.error(error!)
                            
                            // Load local data for authenticated player.
                            self.loadPlayerDataFromLocalStorage(userLastPlayerIfNeeded: false)
                            self.notifyObserversDidAuthenticatePlayer(oldPlayer, newPlayer: self.player)
                            
                        } else {
                            if let savedGame = savedGames?.last {
                                
                                // Load GameCenter data for authenticated player.
                                savedGame.loadDataWithCompletionHandler({ (data: NSData?, error: NSError?) in
                                    if error != nil {
                                        
                                        // Load local data for authenticated player.
                                        Analytics.error(error!)
                                        self.loadPlayerDataFromLocalStorage(userLastPlayerIfNeeded: false)
                                        
                                    } else {
                                        
                                        // Initialize player data with GameCenter data.
                                        let playerDataJSON = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                                        self.playerData = Mapper<PlayerData>().map(playerDataJSON)
                                    }
                                    
                                    self.notifyObserversDidAuthenticatePlayer(oldPlayer, newPlayer: self.player)
                                })
                                
                            } else {
                                // Load default data for authenticated player.
                                self.loadPlayerDataFromLocalStorage(userLastPlayerIfNeeded: false)
                                self.notifyObserversDidAuthenticatePlayer(oldPlayer, newPlayer: self.player)
                            }
                        }
                    })
                    
                } else {
                    // Load local data for guest player.
                    self.loadPlayerDataFromLocalStorage(userLastPlayerIfNeeded: false)
                    self.notifyObserversDidAuthenticatePlayer(oldPlayer, newPlayer: self.player)
                }
            }
        }
        
        startAutoSaveTimer()
    }
    
    private func savePlayer() {
        stopAutoSaveTimer()
        
        guard playerData != nil else { return }
        
        let keys = playerDataKeys()
        let key = player.authenticated ? keys.authenticatedKey! : keys.guestKey
        
        let playerDataJSON = Mapper().toJSONString(playerData, prettyPrint: true)!
        let playerDataBytes = playerDataJSON.dataUsingEncoding(NSUTF8StringEncoding)!
        
        if !keychain.set(playerDataJSON, forKey: key) {
            Analytics.error(NSError(domain: String(KeychainSwift.self), code: Int(keychain.lastResultCode), userInfo: nil))
        }
        if !keychain.set(key, forKey: playerIdentifierKey) {
            Analytics.error(NSError(domain: String(KeychainSwift.self), code: Int(keychain.lastResultCode), userInfo: nil))
        }
        
        player.saveGameData(playerDataBytes, withName: key, completionHandler: { (savedGame, error) in
            Analytics.error(error!)
        })
    }
    
    private func loadPlayerDataFromLocalStorage(userLastPlayerIfNeeded useLastPlayerIfNeeded: Bool) {
        let defaultPlayerDataFileName = "DefaultPlayerData.json"
        
        let keys = playerDataKeys()
        var playerDataJSON: String! = nil
        
        // Load data for currently authenticated player.
        if keys.authenticatedKey != nil {
            playerDataJSON = keychain.get(keys.authenticatedKey!)
        }
        
        if playerDataJSON == nil {
            // Load data for last authenticated player.
            if useLastPlayerIfNeeded && keys.lastSavedKey != nil {
                playerDataJSON = keychain.get(keys.lastSavedKey!)
            }
        }
        
        if playerDataJSON == nil {
            // Load data for guest player.
            playerDataJSON = keychain.get(keys.guestKey)
        }
        
        if playerDataJSON == nil {
            // Load default data.
            playerDataJSON = try! NSString(contentsOfFile: defaultPlayerDataFileName.pathInResourcesBundle(),
                encoding: NSUTF8StringEncoding) as String
        }

        playerData = Mapper<PlayerData>().map(playerDataJSON)
    }
    
    typealias PlayerDataKeys = (authenticatedKey: String?, guestKey: String, lastSavedKey: String?)
    private func playerDataKeys() -> PlayerDataKeys {
        let guestPlayerID = "Guest"
        let authenticatedPlayerID = player.playerID
        
        var keys: PlayerDataKeys = (authenticatedKey: nil, guestKey: "", lastSavedKey: nil)
        
        if player.authenticated {
            keys.authenticatedKey = authenticatedPlayerID!
        }
        keys.guestKey = guestPlayerID
        keys.lastSavedKey = keychain.get(playerIdentifierKey)
        
        return keys
    }
}

extension PlayerManager {
    
    private func startAutoSaveTimer() {
        stopAutoSaveTimer()
        autoSaveTimer = NSTimer(timeInterval: autoSaveTimerInterval,
            target: self,
            selector: Selector("autoSaveTimerDidFire"),
            userInfo: nil,
            repeats: true)
    }
    
    private func stopAutoSaveTimer() {
        autoSaveTimer?.invalidate()
    }
    
    @objc private func autoSaveTimerDidFire() {
        savePlayer()
    }
}

extension PlayerManager {
    
    private func registerForAppLifeCycleNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("appWillResignActive:"), name: UIApplicationWillResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("appDidBecomeActive:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    private func unregisterFromAppLifeCycleNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func appWillResignActive(notification: NSNotification) {
        savePlayer()
    }
    
    @objc private func appDidBecomeActive(notification: NSNotification) {
        loadPlayer()
    }
}

extension PlayerManager {
    
    private func notifyObserversDidEarnChipsToUnlockLevel(levelProgress: LevelProgress) {
        for observer in observers {
            observer.playerManager(self, didEarnChipsToUnlockLevel: levelProgress)
        }
    }
    
    private func notifyObserversDidAuthenticatePlayer(oldPlayer: GKLocalPlayer?, newPlayer: GKLocalPlayer) {
        if oldPlayer == nil || newPlayer.playerID != oldPlayer!.playerID {
            for observer in observers {
                observer.playerManagerDidAuthenticateNewPlayer(self)
            }
        }
    }
}
