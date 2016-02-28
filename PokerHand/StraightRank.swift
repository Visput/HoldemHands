//
//  StraightRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct StraightRank: HandRank {
    
    private(set) var rankCards = QuickArray<Card>()
    
    mutating func validateCards(orderedCards: OrderedCards) -> Bool {
        rankCards.removeAll()
        
        mainLoop: for index in 0 ... orderedCards.cards.count - 4 {
            subLoop: for subIndex in index ..< orderedCards.cards.count {
                if rankCards.count == 0 {
                    rankCards.append(orderedCards.cards[subIndex])
                    
                } else if rankCards.last!.rank.rawValue == orderedCards.cards[subIndex].rank.rawValue + 1 {
                    rankCards.append(orderedCards.cards[subIndex])
                    
                    if rankCards.count == 4 && rankCards.last!.rank == .Two && orderedCards.cards.first!.rank == .Ace {
                        // Wheel Straight.
                        rankCards.append(orderedCards.cards.first!)
                        break mainLoop
                        
                    } else if rankCards.count == 5 {
                        break mainLoop
                    }
                    
                } else if rankCards.last!.rank.rawValue > orderedCards.cards[subIndex].rank.rawValue + 1  {
                    rankCards.removeAll()
                    break subLoop 
                }
            }
            
            rankCards.removeAll()
        }
        
        if rankCards.count == 5 {
            return true
            
        } else {
            return false
        }
    }
}

func ==(lhs: StraightRank, rhs: StraightRank) -> Bool {
    return lhs.rankCards.first!.rank == rhs.rankCards.first!.rank
}

func <(lhs: StraightRank, rhs: StraightRank) -> Bool {
    return lhs.rankCards.first!.rank < rhs.rankCards.first!.rank
}