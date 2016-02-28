//
//  FourOfKindRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct FourOfKindRank: HandRank {
    
    private(set) var rankCard: Card!
    private(set) var highCardRank = HighCardRank()
    
    mutating func validateCards(var orderedCards: OrderedCards) -> Bool {
        rankCard = nil
        
        for index in 0 ... orderedCards.cards.count - 4 {
            if orderedCards.cards[index].rank == orderedCards.cards[index + 1].rank &&
                orderedCards.cards[index].rank == orderedCards.cards[index + 2].rank &&
                orderedCards.cards[index].rank == orderedCards.cards[index + 3].rank{
                    
                    rankCard = orderedCards.cards[index]
                    orderedCards.removeAtIndex(index + 3)
                    orderedCards.removeAtIndex(index + 2)
                    orderedCards.removeAtIndex(index + 1)
                    orderedCards.removeAtIndex(index)
                    break
            }
        }
        
        if rankCard != nil {
            highCardRank.validateCards(orderedCards, numberOfSignificantCards: 1)
            return true
            
        } else {
            return false
        }
    }
}

func ==(lhs: FourOfKindRank, rhs: FourOfKindRank) -> Bool {
    return lhs.rankCard.rank == rhs.rankCard.rank && lhs.highCardRank == rhs.highCardRank
}

func <(lhs: FourOfKindRank, rhs: FourOfKindRank) -> Bool {
    return lhs.rankCard.rank < rhs.rankCard.rank || (lhs.rankCard.rank == rhs.rankCard.rank && lhs.highCardRank < rhs.highCardRank)
}