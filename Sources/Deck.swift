//
//  Deck.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/17/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct Deck {
    
    var cards: [Card]
    
    init() {
        cards = [Card]()
        for var suit = Suit.Spades.rawValue; suit <= Suit.Clubs.rawValue; suit++ {
            for var rank = Rank.Two.rawValue; rank <= Rank.Ace.rawValue; rank++ {
                let card = Card(rank: Rank(rawValue: rank)!, suit: Suit(rawValue: suit)!)
                cards.append(card)
            }
        }
        shuffleCards()
    }
    
    mutating func nextHand() -> Hand {
        let firstCard = cards.removeFirst()
        let secondCard = cards.removeFirst()
        
        if firstCard.rank > secondCard.rank {
            return Hand(firstCard: firstCard, secondCard: secondCard)
        } else {
            return Hand(firstCard: secondCard, secondCard: firstCard)
        }
    }
    
    mutating func removeHand(hand: Hand) {
        cards.removeAtIndex(cards.indexOf(hand.firstCard)!)
        cards.removeAtIndex(cards.indexOf(hand.secondCard)!)
    }
    
    mutating func sortCards() {
        cards.sortInPlace({ (lhs, rhs) -> Bool in
            lhs.rank > rhs.rank
        })
    }
    
    private mutating func shuffleCards() {
        let count = cards.count
        for i in 0 ..< count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&cards[i], &cards[j])
        }
    }
}
