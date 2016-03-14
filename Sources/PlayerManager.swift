//
//  PlayerManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import GameKit
import ObjectMapper

final class PlayerManager {
    
    let observers = ObserverSet<PlayerManagerObserving>()
    
    private(set) var playerData: PlayerData!
    private var player: GKLocalPlayer!

    private let navigationManager: NavigationManager
    private var autoSaveTimer: NSTimer?
    private let autoSaveTimerInterval = 300.0 // Secs.
    
    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
        loadPlayer()
        registerForAppLifeCycleNotifications()
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
        
        let progressItem = progressItemForLevel(level)
        let newLevelProgress = progressItem.progress.levelProgressByIncrementingNumberOfWins(chipsWon: chipsWon)
        playerData.levelProgressItems[progressItem.index] = newLevelProgress
        
        if newLevelProgress.maxNumberOfWinsInRow > progressItem.progress.maxNumberOfWinsInRow {
            notifyObserversDidSetNewWinRecordForLevel(newLevelProgress)
        }
        
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
        var chipsCount: Int64 = 0
        
        for levelProgress in playerData.levelProgressItems {
            maxNumberOfWinsInRow = max(maxNumberOfWinsInRow, levelProgress.maxNumberOfWinsInRow)
            numberOfWins += levelProgress.numberOfWins
            numberOfLosses += levelProgress.numberOfLosses
            chipsCount += levelProgress.chipsCount
        }
        
        return PlayerProgress(maxNumberOfWinsInRow: maxNumberOfWinsInRow,
            numberOfWins: numberOfWins,
            numberOfLosses: numberOfLosses,
            chipsCount: chipsCount)
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
}

extension PlayerManager {
    
    private func loadPlayer() {
        let currentPlayer: GKLocalPlayer? = player
        
        player = GKLocalPlayer.localPlayer()
        player.authenticateHandler = { [unowned self] (viewController: UIViewController?, error: NSError?) in
            if viewController != nil {
                self.navigationManager.presentScreen(viewController!, animated: true)
            } else {
                if error != nil {
                    Crashlytics.sharedInstance().recordError(error!)
                }
                
                if self.player.authenticated {
                    Crashlytics.sharedInstance().setUserName(self.player.displayName)
                    Crashlytics.sharedInstance().setUserIdentifier(self.player.playerID)
                    
                    self.player.fetchSavedGamesWithCompletionHandler({ (savedGames: [GKSavedGame]?, error: NSError?) in
                        if error != nil {
                            Crashlytics.sharedInstance().recordError(error!)
                            self.loadPlayerDataFromLocalStorage()
                            
                            if self.player.playerID != currentPlayer?.playerID {
                                self.notifyObserversDidAuthenticateNewPlayer()
                            }
                            
                        } else {
                            if let savedGame = savedGames?.last {
                                savedGame.loadDataWithCompletionHandler({ (data: NSData?, error: NSError?) in
                                    if error != nil {
                                        Crashlytics.sharedInstance().recordError(error!)
                                        self.loadPlayerDataFromLocalStorage()
                                        
                                    } else {
                                        let playerDataJSON = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                                        self.playerData = Mapper<PlayerData>().map(playerDataJSON)
                                    }
                                    
                                    if self.player.playerID != currentPlayer?.playerID {
                                        self.notifyObserversDidAuthenticateNewPlayer()
                                    }
                                })
                                
                            } else {
                                self.loadPlayerDataFromLocalStorage()
                                
                                if self.player.playerID != currentPlayer?.playerID {
                                    self.notifyObserversDidAuthenticateNewPlayer()
                                }
                            }
                        }
                    })
                    
                } else {
                    self.loadPlayerDataFromLocalStorage()
                    
                    if currentPlayer == nil || currentPlayer!.playerID != nil {
                        self.notifyObserversDidAuthenticateNewPlayer()
                    }
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
        
        playerDataBytes.writeToFile(key.pathInDocumentsDirectory(), atomically: true)
        
        player.saveGameData(playerDataBytes, withName: key, completionHandler: { (savedGame: GKSavedGame?, error: NSError?) in
            if error != nil {
                Crashlytics.sharedInstance().recordError(error!)
            }
        })
    }
    
    private func loadPlayerDataFromLocalStorage() {
        let defaultPlayerDataFileName = "DefaultPlayerData.json"
        
        let keys = playerDataKeys()
        let fileManager = NSFileManager.defaultManager()
        var playerDataFilePath: String! = nil
        
        playerDataFilePath = keys.authenticatedKey?.pathInDocumentsDirectory() ?? ""
        if !fileManager.fileExistsAtPath(playerDataFilePath) {
            
            playerDataFilePath = keys.guestKey.pathInDocumentsDirectory()
            if !fileManager.fileExistsAtPath(playerDataFilePath) {
                
                playerDataFilePath = defaultPlayerDataFileName.pathInResourcesBundle()
            }
        }
        
        let playerDataJSON = try! NSString(contentsOfFile: playerDataFilePath, encoding: NSUTF8StringEncoding) as String
        playerData = Mapper<PlayerData>().map(playerDataJSON)
    }
    
    private func playerDataKeys() -> (authenticatedKey: String?, guestKey: String) {
        let playerDataKeyPrefix = "PlayerData"
        let guestPlayerID = "Guest"
        let authenticatedPlayerID = player.playerID
        
        var keys: (authenticatedKey: String?, guestKey: String) = (authenticatedKey: nil, guestKey: "")
        
        if player.authenticated {
            keys.authenticatedKey = playerDataKeyPrefix + authenticatedPlayerID!
        }
        keys.guestKey = playerDataKeyPrefix + guestPlayerID
        
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
    
    private func notifyObserversDidSetNewWinRecordForLevel(levelProgress: LevelProgress) {
        for observer in observers {
            observer.playerManager(self, didSetNewWinRecordForLevel: levelProgress)
        }
    }
    
    private func notifyObserversDidAuthenticateNewPlayer() {
        for observer in observers {
            observer.playerManagerDidAuthenticateNewPlayer(self)
        }
    }
}
