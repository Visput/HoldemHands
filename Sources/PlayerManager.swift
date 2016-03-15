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
    private let autoSaveTimerInterval = 60.0 // Secs.
    private let playerIdentifierKey = "PlayerIdentifier"
    
    var authenticated: Bool {
        return player.authenticated
    }
    
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
        
        for levelProgress in playerData.levelProgressItems {
            maxNumberOfWinsInRow = max(maxNumberOfWinsInRow, levelProgress.maxNumberOfWinsInRow)
            numberOfWins += levelProgress.numberOfWins
            numberOfLosses += levelProgress.numberOfLosses
        }
        
        return PlayerProgress(maxNumberOfWinsInRow: maxNumberOfWinsInRow,
            numberOfWins: numberOfWins,
            numberOfLosses: numberOfLosses,
            chipsCount: playerData.chipsCount)
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
                if error != nil {
                    Crashlytics.sharedInstance().recordError(error!)
                }
                
                if self.player.authenticated {
                    Crashlytics.sharedInstance().setUserName(self.player.alias)
                    Crashlytics.sharedInstance().setUserIdentifier(self.player.playerID)
                    
                    // Load GKSavedGame objects for authenticated player.
                    self.player.fetchSavedGamesWithCompletionHandler({ (savedGames: [GKSavedGame]?, error: NSError?) in
                        if error != nil {
                            Crashlytics.sharedInstance().recordError(error!)
                            
                            // Load local data for authenticated player.
                            self.loadPlayerDataFromLocalStorage(userLastPlayerIfNeeded: false)
                            self.notifyObserversDidAuthenticatePlayer(oldPlayer, newPlayer: self.player)
                            
                        } else {
                            if let savedGame = savedGames?.last {
                                
                                // Load GameCenter data for authenticated player.
                                savedGame.loadDataWithCompletionHandler({ (data: NSData?, error: NSError?) in
                                    if error != nil {
                                        
                                        // Load local data for authenticated player.
                                        Crashlytics.sharedInstance().recordError(error!)
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
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let keys = playerDataKeys()
        let key = player.authenticated ? keys.authenticatedKey! : keys.guestKey
        
        let playerDataJSON = Mapper().toJSONString(playerData, prettyPrint: true)!
        let playerDataBytes = playerDataJSON.dataUsingEncoding(NSUTF8StringEncoding)!
        
        playerDataBytes.writeToFile(key.pathInDocumentsDirectory(), atomically: true)
        
        userDefaults.setObject(key, forKey: playerIdentifierKey)
        userDefaults.synchronize()
        
        player.saveGameData(playerDataBytes, withName: key, completionHandler: { (savedGame: GKSavedGame?, error: NSError?) in
            if error != nil {
                Crashlytics.sharedInstance().recordError(error!)
            }
        })
    }
    
    private func loadPlayerDataFromLocalStorage(userLastPlayerIfNeeded useLastPlayerIfNeeded: Bool) {
        let defaultPlayerDataFileName = "DefaultPlayerData.json"
        
        let keys = playerDataKeys()
        let fileManager = NSFileManager.defaultManager()
        var playerDataFilePath: String! = nil
        
        // Load data for currently authenticated player.
        playerDataFilePath = keys.authenticatedKey?.pathInDocumentsDirectory() ?? ""
        if !fileManager.fileExistsAtPath(playerDataFilePath) {
            
            // Load data for last authenticated player.
            if useLastPlayerIfNeeded && keys.lastSavedKey != nil {
                playerDataFilePath = keys.lastSavedKey!.pathInDocumentsDirectory()
                
            } else {
                // Load data for guest player.
                playerDataFilePath = keys.guestKey.pathInDocumentsDirectory()
                if !fileManager.fileExistsAtPath(playerDataFilePath) {
                    
                    // Load default data.
                    playerDataFilePath = defaultPlayerDataFileName.pathInResourcesBundle()
                }
            }
        }
        
        let playerDataJSON = try! NSString(contentsOfFile: playerDataFilePath, encoding: NSUTF8StringEncoding) as String
        playerData = Mapper<PlayerData>().map(playerDataJSON)
    }
    
    typealias PlayerDataKeys = (authenticatedKey: String?, guestKey: String, lastSavedKey: String?)
    private func playerDataKeys() -> PlayerDataKeys {
        let guestPlayerID = "Guest"
        let authenticatedPlayerID = player.playerID
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        var keys: PlayerDataKeys = (authenticatedKey: nil, guestKey: "", lastSavedKey: nil)
        
        if player.authenticated {
            keys.authenticatedKey = authenticatedPlayerID!
        }
        keys.guestKey = guestPlayerID
        keys.lastSavedKey = userDefaults.stringForKey(playerIdentifierKey)
        
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
    
    private func notifyObserversDidAuthenticatePlayer(oldPlayer: GKLocalPlayer?, newPlayer: GKLocalPlayer) {
        if oldPlayer == nil || newPlayer.playerID != oldPlayer!.playerID {
            for observer in observers {
                observer.playerManagerDidAuthenticateNewPlayer(self)
            }
        }
    }
}
