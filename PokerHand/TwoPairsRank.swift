//
//  TwoPairsRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct TwoPairsRank: HandRank {
    
    private(set) var highPairRank = PairRank()
    private(set) var lowPairRank = PairRank()
    private(set) var highCardRank = HighCardRank()
    
    mutating func validateCards(orderedCards: OrderedCards) -> Bool {
        if highPairRank.validateCards(orderedCards) {
            if lowPairRank.validateCards(highPairRank.highCardRank.orderedRankCards) {
                highCardRank.validateCards(lowPairRank.highCardRank.orderedRankCards, numberOfSignificantCards: 1)
                return true
                
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
}

func ==(lhs: TwoPairsRank, rhs: TwoPairsRank) -> Bool {
    return lhs.highPairRank.rankCard.rank == rhs.highPairRank.rankCard.rank &&
        lhs.lowPairRank.rankCard.rank == rhs.lowPairRank.rankCard.rank &&
        lhs.highCardRank == rhs.highCardRank
}

func <(lhs: TwoPairsRank, rhs: TwoPairsRank) -> Bool {
    return (lhs.highPairRank.rankCard.rank == rhs.highPairRank.rankCard.rank &&
        lhs.lowPairRank.rankCard.rank == rhs.lowPairRank.rankCard.rank &&
        lhs.highCardRank < rhs.highCardRank) ||
        (lhs.highPairRank.rankCard.rank == rhs.highPairRank.rankCard.rank &&
            lhs.lowPairRank.rankCard.rank < rhs.lowPairRank.rankCard.rank) ||
        (lhs.highPairRank.rankCard.rank < rhs.highPairRank.rankCard.rank)
}