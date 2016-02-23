//
//  HandRankCalculator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/23/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandRankComparator<HandRankType: HandRank> {
    
    static func compareHands(inout handsOdds: [HandOdds], boardCards: [Card]) -> Bool {
        var firstHandOdds = handsOdds[0]
        var secondHandOdds = handsOdds[1]
        
        var firstCards = boardCards
        firstCards.appendContentsOf([firstHandOdds.hand.firstCard, firstHandOdds.hand.secondCard])
        let firstOrderedCards = OrderedCards(cards: firstCards)
        let firstHandRank = HandRankType(orderedCards: firstOrderedCards)
        
        var secondCards = boardCards
        secondCards.appendContentsOf([secondHandOdds.hand.firstCard, secondHandOdds.hand.secondCard])
        let secondOrderedCards = OrderedCards(cards: secondCards)
        let secondHandRank = HandRankType(orderedCards: secondOrderedCards)
        
        if firstHandRank != nil && secondHandRank != nil {
            if firstHandRank == secondHandRank {
                firstHandOdds.tieCombinationsCount += 1
                secondHandOdds.tieCombinationsCount += 1
                return true
                
            } else if firstHandRank > secondHandRank {
                firstHandOdds.winningCombinationsCount += 1
                return true
                
            } else {
                secondHandOdds.winningCombinationsCount += 1
                return true
            }
            
        } else if firstHandRank != nil {
            firstHandOdds.winningCombinationsCount += 1
            return true
            
        } else if secondHandRank != nil {
            secondHandOdds.winningCombinationsCount += 1
            return true
            
        } else {
            return false
        }
    }
}