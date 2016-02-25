//
//  HandRankCalculator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/23/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandRankComparator<HandRankType: HandRank> {
    
    static func compareHands(inout handsOdds: [HandOdds], orderedBoards: [OrderedCards]) -> Bool {
        let firstHandRank = HandRankType(orderedCards: orderedBoards[0])
        let secondHandRank = HandRankType(orderedCards: orderedBoards[1])
        
        if firstHandRank == nil && secondHandRank == nil {
            return false
            
        } else if firstHandRank != nil && secondHandRank != nil {
            if firstHandRank! == secondHandRank! {
                handsOdds[0].tieCombinationsCount += 1
                handsOdds[1].tieCombinationsCount += 1
                return true
                
            } else if firstHandRank! > secondHandRank! {
                handsOdds[0].winningCombinationsCount += 1
                return true
                
            } else {
                handsOdds[1].winningCombinationsCount += 1
                return true
            }
            
        } else if firstHandRank != nil {
            handsOdds[0].winningCombinationsCount += 1
            return true
            
        } else {
            handsOdds[1].winningCombinationsCount += 1
            return true
        }
    }
}