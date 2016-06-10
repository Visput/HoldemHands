//
//  GameManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 6/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

final class GameManager {
    
    private(set) var currentRound: GameRound!
    private(set) var nextRound: GameRound!
    
    private let level: Level
    private let playerManager: PlayerManager
    
    init(level: Level, playerManager: PlayerManager) {
        self.level = level
        self.playerManager = playerManager
    }
    
    func start() {
        stop()
        if let incompleteRound = playerManager.playerData.progressForLevel(level).instance.incompleteRound {
            currentRound = incompleteRound
        } else {
            currentRound = GameRound(level: level)
        }
        
        nextRound = GameRound(level: level)
    }
    
    func stop() {
        
    }
    
    func pause() {
        
    }
    
    func selectHand(hand: Hand) {
        
    }
}
