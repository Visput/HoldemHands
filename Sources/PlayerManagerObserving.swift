//
//  PlayerManagerObserving.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

protocol PlayerManagerObserving: AnyObject {
    
    func playerManager(manager: PlayerManager, didUnlockLevel levelProgress: LevelProgress)
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData)
    func playerManager(manager: PlayerManager, didUpdateChipsCount newChipsCount: Int64, oldChipsCount: Int64, chipsMultiplier: Int64)
}

// Use empty implementations to make methods optional.
extension PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didUnlockLevel levelProgress: LevelProgress) {}
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {}
    func playerManager(manager: PlayerManager, didUpdateChipsCount newChipsCount: Int64, oldChipsCount: Int64, chipsMultiplier: Int64) {}
}
