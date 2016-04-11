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

final class PlayerManager: NSObject {
    
    enum ErrorCode: Int {
        case FailedToLoadRankFromGameCenter
    }
    
    let errorDomain = "PlayerManagerErrorDomain"
    
    let observers = ObserverSet<PlayerManagerObserving>()
    
    private(set) var playerData: PlayerData!
    private var player: GKLocalPlayer

    private let navigationManager: NavigationManager
    private var autoSaveTimer: NSTimer?
    private let autoSaveTimerInterval = 120.0 // Secs.
    private let playerIdentifierKey = "PlayerIdentifier"
    private let keychain = KeychainSwift()
    
    var authenticated: Bool {
        return player.authenticated
    }
    
    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
        player = GKLocalPlayer.localPlayer()
        super.init()
        player.registerListener(self)
        loadPlayerData()
    }
    
    deinit {
        unregisterFromAppLifeCycleNotifications()
    }
    
    func isLockedLevel(level: Level) -> Bool {
        let progress = progressItemForLevel(level).progress
        return progress.locked
    }
    
    func trackNewWinInLevel(level: Level) {
        let oldChipsCount = playerData.chipsCount
        let chipsMultiplier = chipsMultiplierForLevel(level)
        let chipsWon = level.chipsPerWin * chipsMultiplier
        playerData.chipsCount! += chipsWon
        
        let progressItem = progressItemForLevel(level)
        let newLevelProgress = progressItem.progress.levelProgressByIncrementingWinsCount(chipsWon: chipsWon)
        playerData.levelProgressItems[progressItem.index] = newLevelProgress
        
        notifyObserversDidUpdateChipsCount(playerData.chipsCount, oldChipsCount: oldChipsCount, chipsMultiplier: chipsMultiplier)
        
        updateLockStateForLevels()
    }
    
    func trackNewLossInLevel(level: Level) {
        let oldChipsCount = playerData.chipsCount
        let chipsLost = level.chipsPerWin
        // Total chips count can not be less than zero.
        playerData.chipsCount = max(Int64(0), playerData.chipsCount - chipsLost)

        let progressItem = progressItemForLevel(level)
        
        let newLevelProgress = progressItem.progress.levelProgressByIncrementingLossesCount(chipsLost: chipsLost)
        playerData.levelProgressItems[progressItem.index] = newLevelProgress
        
        guard playerData.chipsCount != oldChipsCount else { return }
        notifyObserversDidUpdateChipsCount(playerData.chipsCount, oldChipsCount: oldChipsCount, chipsMultiplier: 1)
    }
    
    func chipsMultiplierForLevel(level: Level) -> Int64 {
        let progressItem = progressItemForLevel(level)
        return Int64(pow(2, Double(progressItem.progress.currentWinsCountInRow / level.winsInRowToDoubleChips)))
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
                            let progressItemWithRank = progress.levelProgressBySettingRank(leaderboard.localPlayerScore?.rank)
                            self.playerData.levelProgressItems[index] = progressItemWithRank
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
            var levelProgress = playerData.levelProgressItems[index]
            if levelProgress.locked! && levelProgress.level.chipsToUnlock <= playerData.chipsCount {
                levelProgress = levelProgress.levelProgressBySettingUnlocked()
                playerData.levelProgressItems[index] = levelProgress
                
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
        // Use last saved data while actual data is loading from GameCenter.
        loadPlayerDataFromLocalStorage(useLastPlayerIfNeeded: true)
        
        // Authenticate current user and load data from GameCenter.
        player.authenticateHandler = { [unowned self] viewController, error in
            
            // Register for notifications when `authenticateHandler` executed at least once.
            // This prevents from calling authentication twice when app is launched.
            self.registerForAppLifeCycleNotifications()
            
            guard viewController == nil else {
                // Present authentication screen.
                self.navigationManager.presentScreen(viewController!, animated: true)
                return
            }
            
            guard self.player.authenticated else {
                Analytics.error(error)
                
                // Load local data for guest player.
                self.loadPlayerDataFromLocalStorage(useLastPlayerIfNeeded: false)
                return
            }
            
            Analytics.userName(self.player.alias)
            Analytics.userID(self.player.playerID)
            
            // Load GKSavedGame objects for authenticated player.
            self.player.fetchSavedGamesWithCompletionHandler({ savedGames, error in
                guard error == nil else {
                    Analytics.error(error)
                    
                    // Load local data for authenticated player.
                    self.loadPlayerDataFromLocalStorage(useLastPlayerIfNeeded: false)
                    return
                }
                
                guard let recentSavedGame = self.mostRecentSavedGameInGames(savedGames) else {
                    // Load default data for authenticated player.
                    self.loadPlayerDataFromLocalStorage(useLastPlayerIfNeeded: false)
                    return
                }
                
                // Load GameCenter data for authenticated player.
                recentSavedGame.loadDataWithCompletionHandler({ data, error in
                    guard error == nil else {
                        Analytics.error(error)
                        
                        // Load local data for authenticated player.
                        self.loadPlayerDataFromLocalStorage(useLastPlayerIfNeeded: false)
                        return
                    }
                    
                    // Initialize player data with GameCenter data.
                    self.initializePlayerDataWithJSONData(data!)
                })
            })
        }
    }
    
    func savePlayerData() {
        guard playerData != nil else { return }
        
        let keys = playerDataKeys()
        let key = player.authenticated ? keys.authenticatedKey! : keys.guestKey
        
        playerData.generateTimestamp()
        let playerDataJSON = Mapper().toJSONString(playerData, prettyPrint: true)!
        let playerDataBytes = playerDataJSON.dataUsingEncoding(NSUTF8StringEncoding)!
        
        if !keychain.set(playerDataJSON, forKey: key) {
            Analytics.error(NSError(domain: String(KeychainSwift.self), code: Int(keychain.lastResultCode), userInfo: nil))
        }
        if !keychain.set(key, forKey: playerIdentifierKey) {
            Analytics.error(NSError(domain: String(KeychainSwift.self), code: Int(keychain.lastResultCode), userInfo: nil))
        }
        
        if player.authenticated {
            player.saveGameData(playerDataBytes, withName: key, completionHandler: { (savedGame, error) in
                Analytics.error(error)
            })
            
            reportScores()
        }
    }
    
    private func loadPlayerDataFromLocalStorage(useLastPlayerIfNeeded useLastPlayerIfNeeded: Bool) {
        let defaultPlayerDataFileName = NSBundle.mainBundle().objectForInfoDictionaryKey("DefaultPlayerDataFileName") as! String
        
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

        initializePlayerDataWithJSONString(playerDataJSON)
    }
    
    private func initializePlayerDataWithJSONData(jsonData: NSData) {
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        initializePlayerDataWithJSONString(jsonString)
    }
    
    private func initializePlayerDataWithJSONString(jsonString: String) {
        let gameDataFileName = NSBundle.mainBundle().objectForInfoDictionaryKey("GameDataFileName") as! String
        let overallLeaderboardIDKey = "overall_leaderboard_id"
        let levelsKey = "levels"
        
        let newPlayerData = Mapper<PlayerData>().map(jsonString)
        if playerData?.timestamp < newPlayerData!.timestamp {
            playerData = newPlayerData
            
            // Fill player data with game data.
            let gameData = NSData(contentsOfFile: gameDataFileName.pathInResourcesBundle())!
            let gameDataJSON = try! NSJSONSerialization.JSONObjectWithData(gameData, options: .AllowFragments) as! [String : AnyObject]
            
            playerData.overallLeaderboardID = gameDataJSON[overallLeaderboardIDKey] as! String
            
            let levelsJSON = gameDataJSON[levelsKey]
            let levels = Mapper<Level>().mapArray(levelsJSON)!
            for (index, progress) in playerData.levelProgressItems.enumerate() {
                for level in levels {
                    guard progress.levelID == level.identifier else { continue }
                    playerData.levelProgressItems[index] = progress.levelProgressBySettingLevel(level)
                    break
                }
            }
            updateLockStateForLevels()
            
            notifyObserversDidLoadPlayerData()
        }
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
    
    private func mostRecentSavedGameInGames(savedGames: [GKSavedGame]?) -> GKSavedGame? {
        guard var recentSavedGame = savedGames?.first else { return nil }
        
        for index in 1 ..< savedGames!.count {
            if savedGames![index].modificationDate!.compare(recentSavedGame.modificationDate!) == .OrderedDescending {
                recentSavedGame = savedGames![index]
            }
        }
        
        return recentSavedGame
    }
    
    private func clearPlayerData() {
        keychain.clear()
        guard player.authenticated else { return }
        player.deleteSavedGamesWithName(playerDataKeys().authenticatedKey!, completionHandler: nil)
    }
}

extension PlayerManager: GKLocalPlayerListener {
    
    func player(player: GKPlayer, didModifySavedGame savedGame: GKSavedGame) {
        loadPlayerData()
    }
    
    func player(player: GKPlayer, hasConflictingSavedGames savedGames: [GKSavedGame]) {
        let recentSavedGame = mostRecentSavedGameInGames(savedGames)!
        recentSavedGame.loadDataWithCompletionHandler({ data, error in
            guard error == nil else {
                Analytics.error(error)
                return
            }
            
            self.player.resolveConflictingSavedGames(savedGames,
                withData: data!,
                completionHandler: { savedGame, error in
                    guard error == nil else {
                        Analytics.error(error)
                        return
                    }
                    
                    // Initialize player data with most recent GameCenter data.
                    self.initializePlayerDataWithJSONData(data!)
            })
        })
    }
}

extension PlayerManager {
    
    private func startAutoSaveTimer() {
        stopAutoSaveTimer()
        autoSaveTimer = NSTimer.scheduledTimerWithTimeInterval(autoSaveTimerInterval,
            target: self,
            selector: #selector(PlayerManager.autoSaveTimerDidFire),
            userInfo: nil,
            repeats: true)
    }
    
    private func stopAutoSaveTimer() {
        autoSaveTimer?.invalidate()
    }
    
    @objc private func autoSaveTimerDidFire() {
        savePlayerData()
    }
}

extension PlayerManager {
    
    private func registerForAppLifeCycleNotifications() {
        unregisterFromAppLifeCycleNotifications()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: #selector(PlayerManager.appWillResignActive(_:)),
            name: UIApplicationWillResignActiveNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: #selector(PlayerManager.appDidBecomeActive(_:)),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
    }
    
    private func unregisterFromAppLifeCycleNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func appWillResignActive(notification: NSNotification) {
        savePlayerData()
        stopAutoSaveTimer()
    }
    
    @objc private func appDidBecomeActive(notification: NSNotification) {
        loadPlayerData()
        startAutoSaveTimer()
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
