//
//  HandOdds.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandOdds {
    
    let hand: Hand
    let totalCombinationsCount: Int
    
    var winningCombinationsCount: Int = 0
    var tieCombinationsCount: Int = 0
    
    init(hand: Hand, totalCombinationsCount: Int) {
        self.hand = hand
        self.totalCombinationsCount = totalCombinationsCount
    }
    
    func winningProbability() -> Double {
        return Double(100 * winningCombinationsCount) / Double(totalCombinationsCount)
    }
    
    func tieProbability() -> Double {
        return Double(100 * tieCombinationsCount) / Double(totalCombinationsCount)
    }
}
