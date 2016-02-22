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
    let winningCombinationsCount: Int
    let tieCombinationsCount: Int
    let totalCombinationsCount: Int
    
    init(hand: Hand, winningCombinationsCount: Int, tieCombinationsCount: Int, totalCombinationsCount: Int) {
        self.hand = hand
        self.winningCombinationsCount = winningCombinationsCount
        self.tieCombinationsCount = tieCombinationsCount
        self.totalCombinationsCount = totalCombinationsCount
    }
}
