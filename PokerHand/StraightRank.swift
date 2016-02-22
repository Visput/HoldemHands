//
//  StraightRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct StraightRank: HandRank {
    
    let rankCards: [Card]
    
    init?(orderedCards: OrderedCards) {
        var rankCards: [Card]? = nil
        
        for index in 0 ... orderedCards.cards.count - 5 {
            let firstCard = orderedCards.cards[index]
            let secondCard = orderedCards.cards[index + 1]
            
            if firstCard.rank.rawValue == secondCard.rank.rawValue + 1 {
                let thirdCard = orderedCards.cards[index + 2]
                
                if secondCard.rank.rawValue == thirdCard.rank.rawValue + 1 {
                    let fourthCard = orderedCards.cards[index + 3]
                    
                    if thirdCard.rank.rawValue == fourthCard.rank.rawValue + 1 {
                        let fifthCard = orderedCards.cards[index + 4]
                    
                        if fourthCard.rank.rawValue == fifthCard.rank.rawValue + 1 {
                            rankCards = [firstCard, secondCard, thirdCard, fourthCard, fifthCard]
                            break
                        }
                    }
                }
            }
        }
        
        if rankCards != nil {
            self.rankCards = rankCards!
        } else {
            return nil
        }
    }
}

func ==(lhs: StraightRank, rhs: StraightRank) -> Bool {
    return lhs.rankCards.first!.rank == rhs.rankCards.first!.rank
}

func <(lhs: StraightRank, rhs: StraightRank) -> Bool {
    return lhs.rankCards.first!.rank < rhs.rankCards.first!.rank
}