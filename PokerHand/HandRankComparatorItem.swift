//
//  HandRankComparatorItem.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/27/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandRankComparatorItem<HandRankType: HandRank>: Equatable {
    
    let handRank: HandRankType
    let handOddsIndex: Int
    
    init(handRank: HandRankType, handOddsIndex: Int) {
        self.handRank = handRank
        self.handOddsIndex = handOddsIndex
    }
}

func ==<HandRankType: HandRank>(lhs: HandRankComparatorItem<HandRankType>, rhs: HandRankComparatorItem<HandRankType>) -> Bool {
    return lhs.handRank == rhs.handRank && lhs.handOddsIndex == rhs.handOddsIndex
}
