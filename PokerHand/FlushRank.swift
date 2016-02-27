//
//  FlushRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

private var cardsStaticArray = [QuickArray<Card>(), QuickArray<Card>(), QuickArray<Card>(), QuickArray<Card>()]

struct FlushRank: HandRank {
    
    let rankCards: QuickArray<Card>
    
    init?(orderedCards: OrderedCards) {
        var rankCards: QuickArray<Card>? = nil
        
        for index in 0 ..< cardsStaticArray.count {
            cardsStaticArray[index].removeAll()
        }
        
        for index in 0 ..< orderedCards.cards.count {
            let card = orderedCards.cards[index]
            let suitIndex = card.suit.rawValue
            cardsStaticArray[suitIndex].append(card)
            
            if cardsStaticArray[suitIndex].count == 5 {
                rankCards = cardsStaticArray[suitIndex]
                break
            }
        }
        
        if rankCards != nil {
            self.rankCards = rankCards!
        } else {
            return nil
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