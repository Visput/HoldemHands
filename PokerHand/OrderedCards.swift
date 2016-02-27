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
    
    init(hand: Hand, boardCards: [Card]) {
        cards = boardCards
        cards.reserveCapacity(boardCards.count + 2)
        
        var firstCardInserted = false
        for (index, card) in boardCards.enumerate() {
            if !firstCardInserted {
                if card.rank < hand.firstCard.rank {
                    firstCardInserted = true
                    
                    cards.insert(hand.firstCard, atIndex: index)
                    if card.rank < hand.secondCard.rank {
                        cards.insert(hand.secondCard, atIndex: index + 1)
                        break
                        
                    } else if index == boardCards.count - 1 {
                        cards.append(hand.secondCard)
                    }
                    
                } else if index == boardCards.count - 1 {
                    cards.append(hand.firstCard)
                    cards.append(hand.secondCard)
                }
                
            } else {
                if card.rank < hand.secondCard.rank {
                    cards.insert(hand.secondCard, atIndex: index + 1)
                    break
                    
                } else if index == boardCards.count - 1 {
                    cards.append(hand.secondCard)
                }
            }
        }
    }
    
    init(orderedCards: [Card]) {
        self.cards = orderedCards
    }
    
    mutating func removeAtIndex(index: Int) -> Card {
        return cards.removeAtIndex(index)
    }
}