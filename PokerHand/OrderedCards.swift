//
//  OrderedCards.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/21/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct OrderedCards {
    
    private(set) var cards: SevenItemsArray<Card>
    
    init(hand: Hand, boardCards: SevenItemsArray<Card>) {
        cards = boardCards
        
        var firstCardInserted = false
        for index in 0 ..< boardCards.count {
            let card = boardCards.itemAtIndex(index)!
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
    
    init(orderedCards: SevenItemsArray<Card>) {
        self.cards = orderedCards
    }
    
    mutating func removeAtIndex(index: Int) {
        cards.removeAtIndex(index)
    }
}