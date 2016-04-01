//
//  HandOdds.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandOdds: Equatable {
    
    var hand: Hand
    var numberOfHands: Int
    var totalCombinationsCount: Int
    
    var winningCombinationsCount: Double = 0
    var tieCombinationsCount: Double = 0
    
    var wins: Bool = false
    
    init(hand: Hand, numberOfHands: Int, totalCombinationsCount: Int) {
        self.hand = hand
        self.numberOfHands = numberOfHands
        self.totalCombinationsCount = totalCombinationsCount
    }
    
    func totalWinningProbability() -> Double {
        return 100.0 * (winningCombinationsCount + tieCombinationsCount) / Double(totalCombinationsCount)
    }
    
    func winningProbability() -> Double {
        return 100.0 * winningCombinationsCount / Double(totalCombinationsCount)
    }
    
    func tieProbability() -> Double {
        return 100.0 * tieCombinationsCount * Double(numberOfHands) / Double(totalCombinationsCount)
    }
}

func == (lhs: HandOdds, rhs: HandOdds) -> Bool {
    return lhs.hand == rhs.hand &&
        lhs.numberOfHands == rhs.numberOfHands &&
        lhs.totalCombinationsCount == rhs.totalCombinationsCount &&
        lhs.winningCombinationsCount == rhs.winningCombinationsCount &&
        lhs.tieCombinationsCount == rhs.tieCombinationsCount
}
