//
//  HighCardRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HighCardRank: HandRank {
    
    let orderedRankCards: OrderedCards
    let numberOfSignificantCards: Int
    
    init?(orderedCards: OrderedCards) {
        self.orderedRankCards = orderedCards
        self.numberOfSignificantCards = 5
    }
    
    init(orderedCards: OrderedCards, numberOfSignificantCards: Int) {
        self.orderedRankCards = orderedCards
        self.numberOfSignificantCards = numberOfSignificantCards
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