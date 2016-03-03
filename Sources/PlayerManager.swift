//
//  PlayerManager.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

class PlayerManager {
    
    let observers = ObserverSet<PlayerManagerObserving>()
    
    private var player: Player!
    
    private let levelsProvider: GameLevelsProvider
    private var autoSaveTimer: NSTimer!
    private let autoSaveTimerInterval = 300.0 // Secs.
    
    init(levelsProvider: GameLevelsProvider) {
        self.levelsProvider = levelsProvider
        registerForAppLifeCycleNotifications()
    }
    
    deinit {
        unregisterFromAppLifeCycleNotifications()
    }
    
    func isUnlockedLevel(level: GameLevel) -> Bool {
        // Level is unlocked if previous level is completed or if it's first level.
        var isUnlocked = false
        for (index, levelProgress) in player.levelProgressItems.enumerate() {
            if levelProgress.level == level {
                if index == 0 {
                    isUnlocked = true
                } else {
                    let previousLevelProgress = player.levelProgressItems[index - 1]
                    isUnlocked = previousLevelProgress.maxNumberOfWinsInRow >= previousLevelProgress.level.numberOfWinsInRowToComplete
                }
                break
            }
        }
        
        return isUnlocked
    }
    
    func trackNewWinInLevel(level: GameLevel) {
        for (index, levelProgress) in player.levelProgressItems.enumerate() {
            guard levelProgress.level == level else { continue }
            
            let newLevelProgress = levelProgress.levelProgressByIncrementingNumberOfWins()
            
            if newLevelProgress.maxNumberOfWinsInRow > levelProgress.maxNumberOfWinsInRow {
                notifyObserversDidSetNewWinRecordForLevel(newLevelProgress)
            }
            
            if newLevelProgress.currentNumberOfWinsInRow == newLevelProgress.level.numberOfWinsInRowToComplete {
                notifyObserversDidCompleteLevel(newLevelProgress)
            }
            
            player.levelProgressItems[index] = newLevelProgress
        }
    }
    
    func trackNewLossInLevel(level: GameLevel) {
        for (index, levelProgress) in player.levelProgressItems.enumerate() {
            guard levelProgress.level == level else { continue }
            
            let newLevelProgress = levelProgress.levelProgressByIncrementingNumberOfLosses()
            
            player.levelProgressItems[index] = newLevelProgress
        }
    }
}

extension PlayerManager {
    
    private func loadPlayer() {
        if player == nil {
            player = Player()
            for level in levelsProvider.levels {
                player.levelProgressItems.append(GameLevelProgress(level: level))
            }
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
        autoSaveTimer.invalidate()
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
    
    private func notifyObserversDidCompleteLevel(levelProgress: GameLevelProgress) {
        for observer in observers {
            observer.playerManager(self, didCompleteLevel: levelProgress)
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

protocol PlayerManagerObserving: AnyObject {
    
    func playerManager(manager: PlayerManager, didCompleteLevel levelProgress: GameLevelProgress)
    func playerManager(manager: PlayerManager, didSetNewWinRecordForLevel levelProgress: GameLevelProgress)
    func playerManagerDidAuthenticateNewPlayer(manager: PlayerManager)
}
