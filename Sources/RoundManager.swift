//
//  RoundManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 6/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

final class RoundManager: NSObject {
    
    var didPlayRoundHandler: ((round: Round) -> Void)?
    var didUpdateTimeBonusHandler: ((bonus: Int64, bonusMultiplier: Int64) -> Void)?
    private(set) var round: Round?
    private(set) var level: Level
    
    private let playerManager: PlayerManager
    private var bonusTimer: NSTimer?
    private let bonusTimerInterval = Double(2) // Sec.
    
    var roundLoaded: Bool {
        return round?.handsOdds != nil
    }
    
    private var chipsMultiplier: Int64 {
        return playerManager.playerData.chipsMultiplierForLevel(level)
    }
    
    init(level: Level, playerManager: PlayerManager) {
        self.level = level
        self.playerManager = playerManager
    }
    
    func loadNewRound(completionHandler: (() -> Void)? = nil) {
        if let incompleteRound = playerManager.playerData.progressForLevel(level).instance.incompleteRound {
            round = incompleteRound
            playerManager.setIncompleteRound(nil, forLevel: level)
        } else {
            round = Round(level: level)
        }
        // Reset current hands odds before calculating new odds.
        round!.handsOdds = nil
        
        let oddsCalculator = HandOddsCalculator(hands: round!.hands)
        oddsCalculator.calculateOdds { handsOdds in
            self.round!.handsOdds = handsOdds
            completionHandler?()
        }
    }
    
    func startRound() {
        stopRound(saveRoundIfNeeded: false)
        if roundLoaded && !round!.completed {
            didUpdateTimeBonusHandler?(bonus: round!.chipsTimeBonus, bonusMultiplier: chipsMultiplier)
            startBonusTimer()
        }
    }
    
    func stopRound(saveRoundIfNeeded saveRoundIfNeeded: Bool) {
        if saveRoundIfNeeded {
            if let round = round {
                playerManager.setIncompleteRound(round.completed ? nil : round, forLevel: level)
            }
            
            playerManager.trackFinishPlayLevel(level)
        }
        stopBonusTimer()
    }
    
    func selectHand(hand: Hand) {
        Analytics.gameRoundPlayed()
        
        stopRound(saveRoundIfNeeded: false)
        
        round!.selectedHand = hand
        playerManager.trackCompletedRound(round!, inLevel: level)
        didPlayRoundHandler?(round: round!)
    }
}

extension RoundManager {
    
    private func startBonusTimer() {
        stopBonusTimer()
        
        guard round!.chipsTimeBonus != 0 else { return }
        
        bonusTimer = NSTimer.scheduledTimerWithTimeInterval(bonusTimerInterval,
                                                            target: self,
                                                            selector: #selector(RoundManager.bonusTimerDidFire),
                                                            userInfo: nil,
                                                            repeats: true)
    }
    
    private func stopBonusTimer() {
        bonusTimer?.invalidate()
        bonusTimer = nil
    }
    
    @objc private func bonusTimerDidFire() {
        reduceTimeBonus()
        
        if round!.chipsTimeBonus == 0 {
            stopBonusTimer()
        }
    }
}

extension RoundManager {
    
    private func reduceTimeBonus() {
        let chipsPerTimerInterval = Int64(Double(level.maxChipsTimeBonus) * bonusTimerInterval / Double(level.chipsBonusTime))
        round!.chipsTimeBonus = max(0, round!.chipsTimeBonus - chipsPerTimerInterval)
        
        didUpdateTimeBonusHandler?(bonus: round!.chipsTimeBonus, bonusMultiplier: chipsMultiplier)
    }
}
