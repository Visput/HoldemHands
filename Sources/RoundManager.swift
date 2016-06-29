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
    var didUpdateTimeBonusHandler: ((bonus: Int64) -> Void)?
    private(set) var round: Round?
    private(set) var level: Level
    
    private let playerManager: PlayerManager
    private var bonusTimer: NSTimer?
    private let numberOfTimerIntervals = Double(60)
    
    var roundLoaded: Bool {
        return round?.handsOdds != nil
    }
    
    init(level: Level, playerManager: PlayerManager) {
        self.level = level
        self.playerManager = playerManager
    }
    
    func loadNewRound(completion: (() -> Void)? = nil) {
        if let incompleteRound = playerManager.playerData.progressForLevel(level).instance.incompleteRound {
            round = incompleteRound
            playerManager.setIncompleteRound(nil, forLevel: level)
        } else {
            round = Round(level: level)
        }
        
        let oddsCalculator = HandOddsCalculator(hands: round!.hands)
        oddsCalculator.calculateOdds { handsOdds in
            self.round!.handsOdds = handsOdds
            completion?()
        }
    }
    
    func startRound() {
        stopRound(saveRoundIfNeeded: false)
        didUpdateTimeBonusHandler?(bonus: round!.chipsTimeBonus)
        startBonusTimer()
    }
    
    func stopRound(saveRoundIfNeeded saveRoundIfNeeded: Bool) {
        if saveRoundIfNeeded {
            if let round = round where !round.completed {
                playerManager.setIncompleteRound(round, forLevel: level)
            }
            
            playerManager.trackFinishPlayLevel(level)
        }
        stopBonusTimer()
    }
    
    func selectHand(hand: Hand) {
        Analytics.gameRoundPlayed()
        
        stopRound(saveRoundIfNeeded: false)
        
        round!.selectedHand = hand
        if round!.won! {
            playerManager.trackNewWinInLevel(level)
        } else {
            playerManager.trackNewLossInLevel(level)
        }
        didPlayRoundHandler?(round: round!)
    }
}

extension RoundManager {
    
    private func startBonusTimer() {
        stopBonusTimer()
        
        guard round!.chipsTimeBonus != 0 else { return }
        
        let timeInterval = Double(level.chipsBonusTime) / numberOfTimerIntervals
        bonusTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval,
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
        round!.chipsTimeBonus = max(0, round!.chipsTimeBonus! - Int64(Double(level.maxChipsTimeBonus) / numberOfTimerIntervals))
        didUpdateTimeBonusHandler?(bonus: round!.chipsTimeBonus)
        
        if round!.chipsTimeBonus == 0 {
            stopBonusTimer()
        }
    }
}
