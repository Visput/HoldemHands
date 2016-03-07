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
    var totalCombinationsCount: Int = 0
    var winningCombinationsCount: Double = 0
    var wins: Bool = false
    
    init(hand: Hand, totalCombinationsCount: Int) {
        self.hand = hand
        self.totalCombinationsCount = totalCombinationsCount
    }
    
    init(hand: Hand) {
        self.hand = hand
    }
    
    func winningProbability() -> Double {
        return 100.0 * winningCombinationsCount / Double(totalCombinationsCount)
    }
}

func == (lhs: HandOdds, rhs: HandOdds) -> Bool {
    return lhs.hand == rhs.hand &&
        lhs.winningCombinationsCount == rhs.winningCombinationsCount &&
        lhs.totalCombinationsCount == rhs.totalCombinationsCount
}
