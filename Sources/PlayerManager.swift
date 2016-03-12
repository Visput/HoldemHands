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
    
    private let levelsProvider: LevelsProvider
    private var autoSaveTimer: NSTimer?
    private let autoSaveTimerInterval = 300.0 // Secs.
    
    init(levelsProvider: LevelsProvider) {
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
    
    func isLockedLevel(level: Level) -> Bool {
        let progress = progressItemForLevel(level).progress
        return progress.locked
    }
    
    func canUnlockLevel(level: Level) -> Bool {
        return player.chipsCount >= level.chipsToUnlock
    }
    
    func unlockLevel(level: Level) {
        precondition(isLockedLevel(level))
        precondition(canUnlockLevel(level))
        
        player.chipsCount -= level.chipsToUnlock
        let progressItem = progressItemForLevel(level)
        player.levelProgressItems[progressItem.index] = progressItem.progress.levelProgressBySettingUnlocked()
        
        savePlayer()
    }
    
    func trackNewWinInLevel(level: Level) {
        let chipsWon = level.chipsPerWin * chipsMultiplierForLevel(level)
        player.chipsCount += chipsWon
        
        let progressItem = progressItemForLevel(level)
        let newLevelProgress = progressItem.progress.levelProgressByIncrementingNumberOfWins(chipsWon: chipsWon)
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
    
    func trackNewLossInLevel(level: Level) {
        let chipsLost = level.chipsPerWin
        // Total chips count can not be less than zero.
        player.chipsCount = max(0.0, player.chipsCount - chipsLost)
        
        let progressItem = progressItemForLevel(level)
        
        let newLevelProgress = progressItem.progress.levelProgressByIncrementingNumberOfLosses(chipsLost: chipsLost)
        player.levelProgressItems[progressItem.index] = newLevelProgress
    }
    
    func chipsMultiplierForLevel(level: Level) -> Double {
        let progressItem = progressItemForLevel(level)
        return pow(2, Double(progressItem.progress.currentNumberOfWinsInRow / level.winsInRowToDoubleChips))
    }
    
    func levelProgressItems() -> [LevelProgress] {
        return player.levelProgressItems
    }
    
    func playerProgress() -> PlayerProgress {
        var maxNumberOfWinsInRow = 0
        var numberOfWins = 0
        var numberOfLosses = 0
        var chipsCount = 0.0
        
        for levelProgress in levelProgressItems() {
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
        for (index, progress) in levelProgressItems().enumerate() {
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
                player.levelProgressItems.append(LevelProgress(level: level))
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
