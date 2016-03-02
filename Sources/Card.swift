//
//  Card.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/17/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct Card: Equatable, Comparable {
    
    let rank: Rank
    let suit: Suit
}

@inline(__always) func == (lhs: Card, rhs: Card) -> Bool {
    return lhs.rank == rhs.rank && lhs.suit == rhs.suit
}

@inline(__always) func < (lhs: Card, rhs: Card) -> Bool {
    return lhs.rank < lhs.rank
}
