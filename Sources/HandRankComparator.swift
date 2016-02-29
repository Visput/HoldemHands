//
//  HandRankComparator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/23/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandRankComparator {
    
    private var handRanks = QuickArray<HandRankCalculator>()
    private var winningHandRanksIndexes  = QuickArray<Int>()
    
    init(numberOfHands: Int) {
        for _ in 0 ..< numberOfHands {
            handRanks.append(HandRankCalculator())
        }
    }
    
    mutating func compareHands(inout handsOdds: [HandOdds], inout orderedBoards: QuickArray<OrderedCards>) -> Bool {
        
        winningHandRanksIndexes.removeAll()
        
        for index in 0 ..< orderedBoards.count {
            handRanks[index].calculateRankForCards(&orderedBoards[index])
        }
        
        var lastWinningIndex: Int! = nil
        for index in 0 ..< handRanks.count {
            let handRank = handRanks[index]
            
            if winningHandRanksIndexes.count == 0 {
                winningHandRanksIndexes.append(index)
                lastWinningIndex = index
                
            } else if handRanks[lastWinningIndex] == handRank {
                winningHandRanksIndexes.append(index)
                lastWinningIndex = index
                
            } else if handRanks[lastWinningIndex] < handRank {
                winningHandRanksIndexes.removeAll()
                winningHandRanksIndexes.append(index)
                lastWinningIndex = index
            }
        }
        
        if winningHandRanksIndexes.count == 1 {
            handsOdds[winningHandRanksIndexes.first!].winningCombinationsCount += 1
            
        } else {
            for index in 0 ..< winningHandRanksIndexes.count {
                handsOdds[winningHandRanksIndexes[index]].winningCombinationsCount += 1.0 / Double(winningHandRanksIndexes.count)
            }
        }
        
        return true
    }
}
