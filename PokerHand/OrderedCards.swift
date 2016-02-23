//
//  OrderedCards.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/21/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct OrderedCards {
    
    private(set) var cards: [Card]
    
    init(cards: [Card]) {
        self.cards = cards.sort({ (lhs, rhs) -> Bool in
            return lhs.rank > rhs.rank
        })
    }
    
    mutating func removeAtIndex(index: Int) -> Card {
        return cards.removeAtIndex(index)
    }
}