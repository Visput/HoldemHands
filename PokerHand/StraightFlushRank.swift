//
//  StraightFlushRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

private var cardsArray = QuickArray<QuickArray<Card>>()

struct StraightFlushRank: HandRank {

    private(set) var straightRank = StraightRank()
    
    init() {
        if cardsArray.count == 0 {
            cardsArray.append(QuickArray<Card>())
            cardsArray.append(QuickArray<Card>())
            cardsArray.append(QuickArray<Card>())
            cardsArray.append(QuickArray<Card>())
        }
    }
    
    mutating func validateCards(orderedCards: OrderedCards) -> Bool {
        for index in 0 ..< cardsArray.count {
            cardsArray[index].removeAll()
        }
        
        for index in 0 ..< orderedCards.cards.count {
            let card = orderedCards.cards[index]
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
            if straightRank.validateCards(OrderedCards(orderedCards: suitedCards)) {
                return true
                
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
}

func ==(lhs: StraightFlushRank, rhs: StraightFlushRank) -> Bool {
    return lhs.straightRank.rankCards.first!.rank == rhs.straightRank.rankCards.first!.rank
}

func <(lhs: StraightFlushRank, rhs: StraightFlushRank) -> Bool {
    return lhs.straightRank.rankCards.first!.rank < rhs.straightRank.rankCards.first!.rank
}