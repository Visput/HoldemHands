//
//  ThreeOfKindRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct ThreeOfKindRank: HandRank {
    
    let rankCard: Card
    let highCardRank: HighCardRank
    
    init?(var orderedCards: OrderedCards) {
        var rankCard: Card? = nil
        
        for index in 0 ... orderedCards.cards.count - 3 {
            if orderedCards.cards[index].rank == orderedCards.cards[index + 1].rank &&
                orderedCards.cards[index].rank == orderedCards.cards[index + 2].rank {
                    
                    rankCard = orderedCards.cards[index]
                    orderedCards.removeAtIndex(index + 2)
                    orderedCards.removeAtIndex(index + 1)
                    orderedCards.removeAtIndex(index)
                    break
            }
        }
        
        if rankCard != nil {
            self.rankCard = rankCard!
            self.highCardRank = HighCardRank(orderedCards: orderedCards, numberOfSignificantCards: 2)
            
        } else {
            return nil
        }
    }
}

func ==(lhs: ThreeOfKindRank, rhs: ThreeOfKindRank) -> Bool {
    return lhs.rankCard.rank == rhs.rankCard.rank && lhs.highCardRank == rhs.highCardRank
}

func <(lhs: ThreeOfKindRank, rhs: ThreeOfKindRank) -> Bool {
    return lhs.rankCard.rank < rhs.rankCard.rank || (lhs.rankCard.rank == rhs.rankCard.rank && lhs.highCardRank < rhs.highCardRank)
}