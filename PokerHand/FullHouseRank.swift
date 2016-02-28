//
//  FullHouseRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct FullHouseRank: HandRank {
    
    private(set) var threeOfKindRank = ThreeOfKindRank()
    private(set) var pairRank = PairRank()
    
    mutating func validateCards(orderedCards: OrderedCards) -> Bool {
        if threeOfKindRank.validateCards(orderedCards) {
            if pairRank.validateCards(threeOfKindRank.highCardRank.orderedRankCards) {
                return true
                
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
}

func ==(lhs: FullHouseRank, rhs: FullHouseRank) -> Bool {
    return lhs.threeOfKindRank.rankCard.rank == rhs.threeOfKindRank.rankCard.rank &&
        lhs.pairRank.rankCard.rank == rhs.pairRank.rankCard.rank
}

func <(lhs: FullHouseRank, rhs: FullHouseRank) -> Bool {
    return (lhs.threeOfKindRank.rankCard.rank == rhs.threeOfKindRank.rankCard.rank &&
        lhs.pairRank.rankCard.rank < rhs.pairRank.rankCard.rank) ||
        (lhs.threeOfKindRank.rankCard.rank < rhs.threeOfKindRank.rankCard.rank)
}