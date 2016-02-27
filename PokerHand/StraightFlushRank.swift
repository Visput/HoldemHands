//
//  StraightFlushRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

private var cardsStaticArray = [SevenItemsArray<Card>(), SevenItemsArray<Card>(), SevenItemsArray<Card>(), SevenItemsArray<Card>()]

struct StraightFlushRank: HandRank {
    
    let rankCards: SevenItemsArray<Card>
    
    init?(orderedCards: OrderedCards) {
        for index in 0 ..< cardsStaticArray.count {
            cardsStaticArray[index].removeAll()
        }
        
        for index in 0 ..< orderedCards.cards.count {
            let card = orderedCards.cards[index]
            let suitIndex = card.suit.rawValue
            cardsStaticArray[suitIndex].append(card)
        }
        
        var suitedCards = cardsStaticArray[0]
        for index in 1 ..< cardsStaticArray.count {
            if cardsStaticArray[index].count > suitedCards.count {
                suitedCards = cardsStaticArray[index]
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