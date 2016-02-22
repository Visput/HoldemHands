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
        var rankCards: [Card]? = nil
        
        for index in 0 ... orderedCards.cards.count - 5 {
            let firstCard = orderedCards.cards[index]
            let secondCard = orderedCards.cards[index + 1]
            
            if firstCard.rank.rawValue == secondCard.rank.rawValue + 1 && firstCard.suit == secondCard.suit {
                let thirdCard = orderedCards.cards[index + 2]
                
                if secondCard.rank.rawValue == thirdCard.rank.rawValue + 1 && secondCard.suit == thirdCard.suit {
                    let fourthCard = orderedCards.cards[index + 3]
                    
                    if thirdCard.rank.rawValue == fourthCard.rank.rawValue + 1 && thirdCard.suit == fourthCard.suit {
                        let fifthCard = orderedCards.cards[index + 4]
                        
                        if fourthCard.rank.rawValue == fifthCard.rank.rawValue + 1 && fourthCard.suit == fifthCard.suit {
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

func ==(lhs: StraightFlushRank, rhs: StraightFlushRank) -> Bool {
    return lhs.rankCards.first!.rank == rhs.rankCards.first!.rank
}

func <(lhs: StraightFlushRank, rhs: StraightFlushRank) -> Bool {
    return lhs.rankCards.first!.rank < rhs.rankCards.first!.rank
}