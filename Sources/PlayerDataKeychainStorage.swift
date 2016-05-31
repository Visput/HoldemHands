//
//  PlayerDataKeychainStorage.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/31/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import GameKit
import KeychainSwift
import ObjectMapper

struct PlayerDataKeychainStorage {
    
    var lastSavedPlayerId: String? {
        return keychain.get(playerIdentifierKey)
    }
    
    var guestPlayerId: String {
        return "Guest"
    }
    
    private let player: GKLocalPlayer
    private let keychain = KeychainSwift()
    private let playerIdentifierKey = "PlayerIdentifier"
    
    init(player: GKLocalPlayer) {
        self.player = player
    }
    
    func loadPlayerData(useLastPlayerIfNeeded useLastPlayerIfNeeded: Bool) -> PlayerData {
        let defaultPlayerDataFileName = NSBundle.mainBundle().objectForInfoDictionaryKey("DefaultPlayerDataFileName") as! String
        
        var playerDataJSON: String! = nil
        
        // Load data for currently authenticated player.
        if let playerId = player.playerID {
            playerDataJSON = keychain.get(playerId)
        }
        
        if playerDataJSON == nil {
            // Load data for last authenticated player.
            if useLastPlayerIfNeeded {
                if let lastSavedPlayerId = lastSavedPlayerId {
                    playerDataJSON = keychain.get(lastSavedPlayerId)
                }
            }
        }
        
        if playerDataJSON == nil {
            // Load data for guest player.
            playerDataJSON = keychain.get(guestPlayerId)
        }
        
        if playerDataJSON == nil {
            // Load default data.
            playerDataJSON = try! NSString(contentsOfFile: defaultPlayerDataFileName.pathInResourcesBundle(),
                                           encoding: NSUTF8StringEncoding) as String
        }
        
        let playerData = PlayerDataJsonLoader(jsonString: playerDataJSON).playerData
        return playerData
    }
    
    func savePlayerData(playerData: PlayerData) {
        let playerDataJSON = Mapper().toJSONString(playerData, prettyPrint: true)!
        let currentPlayerId = player.playerID ?? guestPlayerId
        
        if !keychain.set(playerDataJSON, forKey: currentPlayerId) {
            Analytics.error(NSError(domain: String(KeychainSwift.self), code: Int(keychain.lastResultCode), userInfo: nil))
        }
        if !keychain.set(currentPlayerId, forKey: playerIdentifierKey) {
            Analytics.error(NSError(domain: String(KeychainSwift.self), code: Int(keychain.lastResultCode), userInfo: nil))
        }
    }
    
    func deletePlayerData() {
        keychain.clear()
    }
}
