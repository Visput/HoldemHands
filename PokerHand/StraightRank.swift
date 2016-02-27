//
//  StraightRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

private var staticRankCards = QuickArray<Card>()

struct StraightRank: HandRank {
    
    let rankCards: QuickArray<Card>
    
    init?(orderedCards: OrderedCards) {
        staticRankCards.removeAll()
        
        mainLoop: for index in 0 ... orderedCards.cards.count - 4 {
            subLoop: for subIndex in index ..< orderedCards.cards.count {
                if staticRankCards.count == 0 {
                    staticRankCards.append(orderedCards.cards[subIndex])
                    
                } else if staticRankCards.last!.rank.rawValue == orderedCards.cards[subIndex].rank.rawValue + 1 {
                    staticRankCards.append(orderedCards.cards[subIndex])
                    
                    if staticRankCards.count == 4 && staticRankCards.last!.rank == .Two && orderedCards.cards.first!.rank == .Ace {
                        // Wheel Straight.
                        staticRankCards.append(orderedCards.cards.first!)
                        break mainLoop
                        
                    } else if staticRankCards.count == 5 {
                        break mainLoop
                    }
                    
                } else if staticRankCards.last!.rank.rawValue > orderedCards.cards[subIndex].rank.rawValue + 1  {
                    staticRankCards.removeAll()
                    break subLoop 
                }
            }
            
            staticRankCards.removeAll()
        }
        
        if staticRankCards.count == 5 {
            self.rankCards = staticRankCards
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