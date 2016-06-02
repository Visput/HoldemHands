//
//  PlayerManagerObserverNotifier.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 6/1/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct PlayerManagerObserverNotifier {
    
    private weak var manager: PlayerManager!
    
    init(playerManager: PlayerManager) {
        self.manager = playerManager
    }
    
    func notifyObserversDidUnlockLevel(levelProgress: LevelProgress) {
        for observer in manager.observers {
            observer.playerManager(manager, didUnlockLevel: levelProgress)
        }
    }
    
    func notifyObserversDidLoadPlayerData(playerData: PlayerData) {
        for observer in manager.observers {
            observer.playerManager(manager, didLoadPlayerData: playerData)
        }
    }
    
    func notifyObserversDidUpdateChipsCount(newChipsCount: Int64, oldChipsCount: Int64, chipsMultiplier: Int64) {
        for observer in manager.observers {
            observer.playerManager(manager, didUpdateChipsCount: newChipsCount, oldChipsCount: oldChipsCount, chipsMultiplier: chipsMultiplier)
        }
    }
    
    func notifyObserversDidUpdateLastPlayedLavel(level: Level) {
        for observer in manager.observers {
            observer.playerManager(manager, didUpdateLastPlayedLevel: level)
        }
    }
}
