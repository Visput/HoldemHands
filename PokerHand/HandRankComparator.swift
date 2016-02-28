//
//  HandRankComparator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/23/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandRankComparator<HandRankType: HandRank> {
    
    private var handRanks = QuickArray<HandRankType>()
    private var validHandRanksIndexes = QuickArray<Int>()
    private var winningHandRanksIndexes  = QuickArray<Int>()
    
    init(numberOfHands: Int) {
        for _ in 0 ..< numberOfHands {
            handRanks.append(HandRankType())
        }
    }
    
    mutating func compareHands(inout handsOdds: [HandOdds], inout orderedBoards: QuickArray<OrderedCards>) -> Bool {
        
        validHandRanksIndexes.removeAll()
        
        for index in 0 ..< orderedBoards.count {
            let orderedBoard = orderedBoards[index]
            if handRanks[index].validateCards(orderedBoard) {
                validHandRanksIndexes.append(index)
            }
        }
        
        guard validHandRanksIndexes.count != 0 else { return false }
        
        winningHandRanksIndexes.removeAll()
        
        for index in 0 ..< validHandRanksIndexes.count {
            let validHandRankIndex = validHandRanksIndexes[index]
            
            if winningHandRanksIndexes.count == 0 {
                winningHandRanksIndexes.append(validHandRankIndex)
                
            } else if handRanks[winningHandRanksIndexes.last!] == handRanks[validHandRankIndex] {
                winningHandRanksIndexes.append(validHandRankIndex)
                
            } else if handRanks[winningHandRanksIndexes.last!] < handRanks[validHandRankIndex] {
                winningHandRanksIndexes.removeAll()
                winningHandRanksIndexes.append(validHandRankIndex)
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