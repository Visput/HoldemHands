//
//  TwoPairsRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct TwoPairsRank: HandRank {
    
    let highPairRank: PairRank
    let lowPairRank: PairRank
    let highCardRank: HighCardRank
    
    init?(orderedCards: OrderedCards) {
        if let highPairRank = PairRank(orderedCards: orderedCards) {
            if let lowPairRank = PairRank(orderedCards: highPairRank.highCardRank.orderedRankCards) {
                self.highPairRank = highPairRank
                self.lowPairRank = lowPairRank
                self.highCardRank = HighCardRank(orderedCards: lowPairRank.highCardRank.orderedRankCards,
                    numberOfSignificantCards: 1)
                
            } else {
                return nil
            }
            
        } else {
            return nil
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