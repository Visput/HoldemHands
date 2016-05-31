//
//  PlayerDataCloudStorage.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/31/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import GameKit
import ObjectMapper

final class PlayerDataCloudStorage: NSObject {
    
    private let player: GKLocalPlayer
    private let navigationManager: NavigationManager
    private let didAutoLoadPlayerDataHandler: (playerData: PlayerData) -> Void
    
    init(player: GKLocalPlayer, navigationManager: NavigationManager, didAutoLoadPlayerDataHandler: (playerData: PlayerData) -> Void) {
        self.player = player
        self.navigationManager = navigationManager
        self.didAutoLoadPlayerDataHandler = didAutoLoadPlayerDataHandler
        super.init()
        
        self.player.registerListener(self)
    }
    
    func loadPlayerDataWithCompletionHandler(completionHandler: (playerData: PlayerData?) -> Void) {
        // Authenticate current user and load data from GameCenter.
        player.authenticateHandler = { [unowned self] viewController, error in
            guard viewController == nil else {
                // Present authentication screen.
                self.navigationManager.presentScreen(viewController!, animated: true)
                return
            }
            
            guard self.player.authenticated else {
                Analytics.error(error)
                completionHandler(playerData: nil)
                return
            }
            
            Analytics.userName(self.player.alias)
            Analytics.userID(self.player.playerID)
            
            // Load GKSavedGame objects for authenticated player.
            self.player.fetchSavedGamesWithCompletionHandler({ savedGames, error in
                guard error == nil else {
                    Analytics.error(error)
                    completionHandler(playerData: nil)
                    return
                }
                
                guard let recentSavedGame = savedGames?.mostRecentSavedGame() else {
                    completionHandler(playerData: nil)
                    return
                }
                
                // Load GameCenter data for authenticated player.
                recentSavedGame.loadDataWithCompletionHandler({ data, error in
                    guard error == nil else {
                        Analytics.error(error)
                        completionHandler(playerData: nil)
                        return
                    }
                    
                    // Initialize player data with GameCenter data.
                    let newPlayerData = PlayerDataJsonLoader(jsonData: data!).playerData
                    completionHandler(playerData: newPlayerData)
                })
            })
        }
    }
    
    func savePlayerData(playerData: PlayerData) {
        if player.authenticated {
            let playerDataJSON = Mapper().toJSONString(playerData, prettyPrint: true)!
            let playerDataBytes = playerDataJSON.dataUsingEncoding(NSUTF8StringEncoding)!
            
            player.saveGameData(playerDataBytes, withName: player.playerID!, completionHandler: { savedGame, error in
                Analytics.error(error)
            })
        }
    }
    
    func deletePlayerData() {
        if player.authenticated {
            player.deleteSavedGamesWithName(player.playerID!, completionHandler: nil)
        }
    }
}

extension PlayerDataCloudStorage: GKLocalPlayerListener {
    
    func player(player: GKPlayer, didModifySavedGame savedGame: GKSavedGame) {
        loadPlayerDataWithCompletionHandler { [unowned self] playerData in
            if let playerData = playerData {
                self.didAutoLoadPlayerDataHandler(playerData: playerData)
            }
        }
    }
    
    func player(player: GKPlayer, hasConflictingSavedGames savedGames: [GKSavedGame]) {
        let recentSavedGame = savedGames.mostRecentSavedGame()!
        recentSavedGame.loadDataWithCompletionHandler({ [unowned self] data, error in
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
                    let playerData = PlayerDataJsonLoader(jsonData: data!).playerData
                    self.didAutoLoadPlayerDataHandler(playerData: playerData)
            })
        })
    }
}
