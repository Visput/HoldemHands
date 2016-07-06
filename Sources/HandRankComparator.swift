//
//  HandRankComparator.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/23/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandRankComparator {
 
    private var handsRanks: QuickArray<HandRankCalculator>
    private var winningHandsRanksIndexes: QuickArray<Int>
    
    init(numberOfHands: Int) {
        handsRanks = QuickArray<HandRankCalculator>(numberOfHands)
        winningHandsRanksIndexes  = QuickArray<Int>(numberOfHands)
        for _ in 0 ..< numberOfHands {
            handsRanks.append(HandRankCalculator())
        }
    }
    
    func destroy() {
        for index in 0 ..< handsRanks.count {
            handsRanks[index].destroy()
        }
        handsRanks.destroy()
        winningHandsRanksIndexes.destroy()
    }
    
    @inline(__always) mutating func compareHands(inout handsOdds: [HandOdds], inout boardCards: QuickArray<Card>) {
        
        winningHandsRanksIndexes.removeAll()
        
        for index in 0 ..< handsOdds.count {
            handsRanks[index].calculateRankForHand(&handsOdds[index].hand, boardCards: &boardCards)
        }
        
        for index in 0 ..< handsRanks.count {
            let handRank = handsRanks[index]
            
            if winningHandsRanksIndexes.isEmpty {
                winningHandsRanksIndexes.append(index)
                
            } else if handsRanks[winningHandsRanksIndexes.last!] == handRank {
                winningHandsRanksIndexes.append(index)
                
            } else if handsRanks[winningHandsRanksIndexes.last!] < handRank {
                winningHandsRanksIndexes.removeAll()
                winningHandsRanksIndexes.append(index)
            }
        }
        
        if winningHandsRanksIndexes.count == 1 {
            handsOdds[winningHandsRanksIndexes.first!].winningCombinationsCount += 1
            
        } else {
            if winningHandsRanksIndexes.count == handsOdds.count {
                for index in 0 ..< winningHandsRanksIndexes.count {
                    handsOdds[winningHandsRanksIndexes[index]].tieCombinationsCount += 1.0 / Double(winningHandsRanksIndexes.count)
                }
                
            } else {
                for index in 0 ..< winningHandsRanksIndexes.count {
                    handsOdds[winningHandsRanksIndexes[index]].winningCombinationsCount += 1.0 / Double(winningHandsRanksIndexes.count)
                }
            }
        }
    }
}
