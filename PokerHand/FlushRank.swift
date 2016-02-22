//
//  FlushRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct FlushRank: HandRank {
    
    let rankCards: [Card]
    
    init?(orderedCards: OrderedCards) {
        var rankCards: [Card]? = nil
        var cardsArray = [[Card](), [Card](), [Card](), [Card]()]
        
        for card in orderedCards.cards {
            let suitIndex = card.suit.rawValue
            cardsArray[suitIndex].append(card)
            
            if cardsArray[suitIndex].count == 5 {
                rankCards = cardsArray[suitIndex]
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