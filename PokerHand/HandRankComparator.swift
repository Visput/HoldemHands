//
//  HandRankComparator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/23/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandRankComparator<HandRankType: HandRank> {
    
    private var handsData = QuickArray<HandRankComparatorItem<HandRankType>>()
    private var winningHandsData = QuickArray<HandRankComparatorItem<HandRankType>>()
    
    mutating func compareHands(inout handsOdds: [HandOdds], inout orderedBoards: QuickArray<OrderedCards>) -> Bool {
        
        handsData.removeAll()
        
        for index in 0 ..< orderedBoards.count {
            let orderedBoard = orderedBoards[index]
            if let handRank = HandRankType(orderedCards: orderedBoard) {
                handsData.append(HandRankComparatorItem(handRank: handRank, handOddsIndex: index))
            }
        }
        
        guard handsData.count != 0 else { return false }
        
        winningHandsData.removeAll()
        
        for index in 0 ..< handsData.count {
            let handData = handsData[index]
            
            if winningHandsData.count == 0 {
                winningHandsData.append(handData)
                
            } else if winningHandsData.last!.handRank == handData.handRank {
                winningHandsData.append(handData)
                
            } else if winningHandsData.last!.handRank < handData.handRank {
                winningHandsData.removeAll()
                winningHandsData.append(handData)
            }
        }
        
        if winningHandsData.count == 1 {
            handsOdds[winningHandsData.first!.handOddsIndex].winningCombinationsCount += 1
            
        } else {
            for index in 0 ..< winningHandsData.count {
                let winningHandData = winningHandsData[index]
                handsOdds[winningHandData.handOddsIndex].winningCombinationsCount += 1.0 / Double(winningHandsData.count)
            }
        }
        
        return true
    }
}