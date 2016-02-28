//
//  HighCardRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HighCardRank: HandRank {
    
    private(set) var orderedRankCards: OrderedCards!
    private(set) var numberOfSignificantCards: Int!
    
    mutating func validateCards(orderedCards: OrderedCards) -> Bool {
        self.orderedRankCards = orderedCards
        self.numberOfSignificantCards = 5
        return true
    }
    
    mutating func validateCards(orderedCards: OrderedCards, numberOfSignificantCards: Int) -> Bool {
        self.orderedRankCards = orderedCards
        self.numberOfSignificantCards = numberOfSignificantCards
        return true
    }
}

func ==(lhs: HighCardRank, rhs: HighCardRank) -> Bool {
    for index in 0 ..< lhs.numberOfSignificantCards {
        if lhs.orderedRankCards.cards[index].rank != rhs.orderedRankCards.cards[index].rank {
            return false
        }
    }
    
    return true
}

func <(lhs: HighCardRank, rhs: HighCardRank) -> Bool {
    for index in 0 ..< lhs.numberOfSignificantCards {
        if lhs.orderedRankCards.cards[index].rank < rhs.orderedRankCards.cards[index].rank {
            return true
        } else if lhs.orderedRankCards.cards[index].rank > rhs.orderedRankCards.cards[index].rank {
            return false
        }
    }
    
    return false
}