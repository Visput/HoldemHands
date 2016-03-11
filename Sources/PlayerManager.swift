//
//  PlayerManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

final class PlayerManager {
    
    let observers = ObserverSet<PlayerManagerObserving>()
    
    private(set) var player: Player!
    
    private let levelsProvider: GameLevelsProvider
    private var autoSaveTimer: NSTimer?
    private let autoSaveTimerInterval = 300.0 // Secs.
    
    init(levelsProvider: GameLevelsProvider) {
        self.levelsProvider = levelsProvider
        loadPlayer()
        registerForAppLifeCycleNotifications()
    }
    
    deinit {
        unregisterFromAppLifeCycleNotifications()
    }
    
    func isAuthenticated() -> Bool {
        return player != nil
    }
    
    func isLockedLevel(level: GameLevel) -> Bool {
        let progress = progressItemForLevel(level).progress
        return progress.locked
    }
    
    func canUnlockLevel(level: GameLevel) -> Bool {
        return player.chipsCount >= level.chipsToUnlock
    }
    
    func unlockLevel(level: GameLevel) {
        precondition(isLockedLevel(level))
        precondition(canUnlockLevel(level))
        
        player.chipsCount -= level.chipsToUnlock
        let progressItem = progressItemForLevel(level)
        player.levelProgressItems[progressItem.index] = progressItem.progress.levelProgressBySettingUnlocked()
        
        savePlayer()
    }
    
    func trackNewWinInLevel(level: GameLevel) {
        player.chipsCount += level.chipsPerWin * chipsMultiplierForLevel(level)
        
        let progressItem = progressItemForLevel(level)
        let newLevelProgress = progressItem.progress.levelProgressByIncrementingNumberOfWins()
        player.levelProgressItems[progressItem.index] = newLevelProgress
        
        if newLevelProgress.maxNumberOfWinsInRow > progressItem.progress.maxNumberOfWinsInRow {
            notifyObserversDidSetNewWinRecordForLevel(newLevelProgress)
        }
        
        guard progressItem.index < player.levelProgressItems.count - 1 else { return }
        var nextLevelProgress = player.levelProgressItems[progressItem.index + 1]
        if nextLevelProgress.locked &&
            !nextLevelProgress.notifiedToUnlock &&
            nextLevelProgress.level.chipsToUnlock <= player.chipsCount {
                
                nextLevelProgress = nextLevelProgress.levelProgressBySettingNotifiedToUnlock()
                player.levelProgressItems[progressItem.index + 1] = nextLevelProgress
                notifyObserversDidEarnChipsToUnlockLevel(nextLevelProgress)
        }
    }
    
    func trackNewLossInLevel(level: GameLevel) {
        let progressItem = progressItemForLevel(level)
        
        let newLevelProgress = progressItem.progress.levelProgressByIncrementingNumberOfLosses()
        player.levelProgressItems[progressItem.index] = newLevelProgress
    }
    
    func chipsMultiplierForLevel(level: GameLevel) -> Double {
        let progressItem = progressItemForLevel(level)
        return pow(2, Double(progressItem.progress.currentNumberOfWinsInRow / level.winsInRowToDoubleChips))
    }
    
    private func progressItemForLevel(level: GameLevel) -> (index: Int, progress: GameLevelProgress) {
        var progressItem: (Int, GameLevelProgress)! = nil
        for (index, progress) in player.levelProgressItems.enumerate() {
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
        if player == nil {
            player = Player()
            for level in levelsProvider.levels {
                player.levelProgressItems.append(GameLevelProgress(level: level))
            }
            unlockLevel(player.levelProgressItems[0].level)
        }
        
        startAutoSaveTimer()
    }
    
    private func savePlayer() {
        stopAutoSaveTimer()
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
    
    private func notifyObserversDidEarnChipsToUnlockLevel(levelProgress: GameLevelProgress) {
        for observer in observers {
            observer.playerManager(self, didEarnChipsToUnlockLevel: levelProgress)
        }
    }
    
    private func notifyObserversDidSetNewWinRecordForLevel(levelProgress: GameLevelProgress) {
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
