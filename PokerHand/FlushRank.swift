//
//  FlushRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct FlushRank: HandRank {
    
    private(set) var rankCards: QuickArray<Card>!
    private var cardsArray = [QuickArray<Card>(), QuickArray<Card>(), QuickArray<Card>(), QuickArray<Card>()]
    
    mutating func validateCards(orderedCards: OrderedCards) -> Bool {
        rankCards = nil
        
        for index in 0 ..< cardsArray.count {
            cardsArray[index].removeAll()
        }
        
        for index in 0 ..< orderedCards.cards.count {
            let card = orderedCards.cards[index]
            let suitIndex = card.suit.rawValue
            cardsArray[suitIndex].append(card)
            
            if cardsArray[suitIndex].count == 5 {
                rankCards = cardsArray[suitIndex]
                break
            }
        }
        
        if rankCards != nil {
            return true
            
        } else {
            return false
        }
    }
}

func ==(lhs: FlushRank, rhs: FlushRank) -> Bool {
    for index in 0 ..< lhs.rankCards.count {
        if lhs.rankCards[index].rank != rhs.rankCards[index].rank {
            return false
        }
    }
    
    return true
}

func <(lhs: FlushRank, rhs: FlushRank) -> Bool {
    for index in 0 ..< lhs.rankCards.count {
        if lhs.rankCards[index].rank < rhs.rankCards[index].rank {
            return true
        } else if lhs.rankCards[index].rank > rhs.rankCards[index].rank {
            return false
        }
    }
    
    return false
}