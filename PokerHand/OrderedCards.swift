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
        self.cards = cards.sort({ (card1: Card, card2: Card) -> Bool in
            return card1.rank > card2.rank
        })
    }
    
    mutating func removeAtIndex(index: Int) -> Card {
        return cards.removeAtIndex(index)
    }
}