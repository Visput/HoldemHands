//
//  GameManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 6/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

final class GameManager {
    
    private(set) var firstRound: Round!
    private(set) var secondRound: Round!
    
    private let level: Level
    private let playerManager: PlayerManager
    
    init(level: Level, playerManager: PlayerManager) {
        self.level = level
        self.playerManager = playerManager
    }
    
    func start() {
        stop()
        if let incompleteRound = playerManager.playerData.progressForLevel(level).instance.incompleteRound {
            firstRound = incompleteRound
            playerManager.setIncompleteRound(nil, forLevel: level)
        } else {
            firstRound = Round(level: level)
        }
        
        secondRound = Round(level: level)
    }
    
    func stop() {
        
    }
    
    func pause() {
        
    }
    
    func selectHand(hand: Hand) {
        
    }
}
