//
//  GameManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 6/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

final class GameManager {
    
    private let level: Level
    private let playerManager: PlayerManager
    
    private(set) var currentRound: GameRound!
    private(set) var nextRound: GameRound!
    
    init(level: Level, playerManager: PlayerManager) {
        self.level = level
        self.playerManager = playerManager
    }
    
    func start() {
        stop()
        currentRound = GameRound(level: level)
        nextRound = GameRound(level: level)
    }
    
    func stop() {
        
    }
    
    func pause() {
        
    }
    
    func selectHand(hand: Hand) {
        
    }
}
