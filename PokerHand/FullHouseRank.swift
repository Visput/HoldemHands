//
//  FullHouseRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct FullHouseRank: HandRank {
    
    let threeOfKindRank: ThreeOfKindRank
    let pairRank: PairRank
    
    init?(orderedCards: OrderedCards) {
        if let threeOfKindRank = ThreeOfKindRank(orderedCards: orderedCards) {
            if let pairRank = PairRank(orderedCards: threeOfKindRank.highCardRank.orderedRankCards) {
                self.threeOfKindRank = threeOfKindRank
                self.pairRank = pairRank
                
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }
}

func ==(lhs: FullHouseRank, rhs: FullHouseRank) -> Bool {
    return lhs.threeOfKindRank.rankCard == rhs.threeOfKindRank.rankCard &&
        lhs.pairRank.rankCard == rhs.pairRank.rankCard
}

func <(lhs: FullHouseRank, rhs: FullHouseRank) -> Bool {
    return (lhs.threeOfKindRank.rankCard == rhs.threeOfKindRank.rankCard &&
        lhs.pairRank.rankCard < rhs.pairRank.rankCard) ||
        (lhs.threeOfKindRank.rankCard < rhs.threeOfKindRank.rankCard)
}