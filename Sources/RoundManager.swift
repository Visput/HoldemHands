//
//  RoundManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 6/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

final class RoundManager {
    
    private(set) var round: Round?
    private(set) var level: Level
    private let playerManager: PlayerManager
    
    init(level: Level, playerManager: PlayerManager) {
        self.level = level
        self.playerManager = playerManager
    }
    
    func start() {
        stop(saveRoundIfNeeded: false)
        if let incompleteRound = playerManager.playerData.progressForLevel(level).instance.incompleteRound {
            round = incompleteRound
            playerManager.setIncompleteRound(nil, forLevel: level)
        } else {
            round = Round(level: level)
        }
    }
    
    func stop(saveRoundIfNeeded saveRoundIfNeeded: Bool) {
        if saveRoundIfNeeded {
            if let round = round where !round.completed {
                playerManager.setIncompleteRound(round, forLevel: level)
            }
            
            playerManager.trackFinishPlayLevel(level)
        }
    }
    
    func selectHand(hand: Hand) {
        Analytics.gameRoundPlayed()
        
        round!.selectedHand = hand
        if round!.oddsCalculator.oddsForHand(hand)!.wins {
            playerManager.trackNewWinInLevel(level)
        } else {
            playerManager.trackNewLossInLevel(level)
        }
    }
}
