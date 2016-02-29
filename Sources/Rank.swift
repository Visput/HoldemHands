//
//  Rank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/17/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

enum Rank: Int, Comparable {
    case Two = 0
    case Three = 1
    case Four = 2
    case Five = 3
    case Six = 4
    case Seven = 5
    case Eight = 6
    case Nine = 7
    case Ten = 8
    case Jack = 9
    case Queen = 10
    case King = 11
    case Ace = 12
}

func < (lhs: Rank, rhs: Rank) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
