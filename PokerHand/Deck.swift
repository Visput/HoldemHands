//
//  Deck.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/17/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct Deck {
    
    private(set) var cards: [Card]
    
    init() {
        cards = [Card]()
        for var suit = Suit.Spades.rawValue; suit <= Suit.Clubs.rawValue; suit++ {
            for var rank = Rank.Two.rawValue; rank <= Rank.Ace.rawValue; rank++ {
                let card = Card(rank: Rank(rawValue: rank)!, suit: Suit(rawValue: suit)!)
                cards.append(card)
                shuffle()
            }
        }
    }
    
    mutating func nextHand() -> Hand {
        return Hand(firstCard: cards.removeFirst(), secondCard: cards.removeFirst())
    }
    
    private mutating func shuffle() {
        let count = cards.count
        for i in 0 ..< count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&cards[i], &cards[j])
        }
    }
}