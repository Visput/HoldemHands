//
//  Card.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/17/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import ObjectMapper

struct Card: Equatable, Mappable {
    
    private(set) var rank: Rank!
    private(set) var suit: Suit!
    
    @inline(__always) init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
    }
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        let transformOfRank = TransformOf<Rank, Int>(fromJSON: { Rank(rawValue: $0!) },
                                                     toJSON: { $0.map { $0.rawValue } })
        let transformOfSuit = TransformOf<Suit, Int>(fromJSON: { Suit(rawValue: $0!) },
                                                     toJSON: { $0.map { $0.rawValue } })
        
        rank <- (map["rank"], transformOfRank)
        suit <- (map["suit"], transformOfSuit)
    }
}

@inline(__always) func == (lhs: Card, rhs: Card) -> Bool {
    return lhs.rank == rhs.rank && lhs.suit == rhs.suit
}
