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
        
        for index in 0 ..< handRanks.count {
            let handRank = handRanks[index]
            
            if winningHandRanksIndexes.count == 0 {
                winningHandRanksIndexes.append(index)
                
            } else if handRanks[winningHandRanksIndexes.last!] == handRank {
                winningHandRanksIndexes.append(index)
                
            } else if handRanks[winningHandRanksIndexes.last!] < handRank {
                winningHandRanksIndexes.removeAll()
                winningHandRanksIndexes.append(index)
            }
        }
        
        if winningHandRanksIndexes.count == 1 {
            handsOdds[winningHandRanksIndexes.first!].winningCombinationsCount += 1
            
        } else {
            for index in 0 ..< winningHandRanksIndexes.count {
                let winningHandRankIndex = winningHandRanksIndexes[index]
                handsOdds[winningHandRankIndex].winningCombinationsCount += 1.0 / Double(winningHandRanksIndexes.count)
            }
        }
        
        return true
    }
}