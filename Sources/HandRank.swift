//
//  HandRankType.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/28/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

enum HandRank: Int, Comparable {
    
    case HighCard = 0
    case Pair = 1
    case TwoPairs = 2
    case ThreeOfKind = 3
    case Straight = 4
    case Flush = 5
    case FullHouse = 6
    case FourOfKind = 7
    case StraightFlush = 8
}

@inline(__always) func < (lhs: HandRank, rhs: HandRank) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
