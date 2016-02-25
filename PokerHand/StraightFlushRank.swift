//
//  StraightFlushRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct StraightFlushRank: HandRank {
    
    let rankCards: [Card]
    
    init?(orderedCards: OrderedCards) {
        var cardsArray = [[Card](), [Card](), [Card](), [Card]()]
        
        for card in orderedCards.cards {
            let suitIndex = card.suit.rawValue
            cardsArray[suitIndex].append(card)
        }
        
        var suitedCards = cardsArray[0]
        for index in 1 ..< cardsArray.count {
            if cardsArray[index].count > suitedCards.count {
                suitedCards = cardsArray[index]
            }
        }
        
        if suitedCards.count >= 5 {
            if let straightRank = StraightRank(orderedCards: OrderedCards(orderedCards: suitedCards)) {
                self.rankCards = straightRank.rankCards
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

func ==(lhs: StraightFlushRank, rhs: StraightFlushRank) -> Bool {
    return lhs.rankCards.first!.rank == rhs.rankCards.first!.rank
}

func <(lhs: StraightFlushRank, rhs: StraightFlushRank) -> Bool {
    return lhs.rankCards.first!.rank < rhs.rankCards.first!.rank
}