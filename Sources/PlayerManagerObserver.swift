//
//  PlayerManagerObserver.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

protocol PlayerManagerObserving: AnyObject {
    
    func playerManager(manager: PlayerManager, didEarnChipsToUnlockLevel levelProgress: GameLevelProgress)
    func playerManager(manager: PlayerManager, didSetNewWinRecordForLevel levelProgress: GameLevelProgress)
    func playerManagerDidAuthenticateNewPlayer(manager: PlayerManager)
}

// Use empty implementations to make methods optional.
extension PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didEarnChipsToUnlockLevel levelProgress: GameLevelProgress) {}
    func playerManager(manager: PlayerManager, didSetNewWinRecordForLevel levelProgress: GameLevelProgress) {}
    func playerManagerDidAuthenticateNewPlayer(manager: PlayerManager) {}
}
