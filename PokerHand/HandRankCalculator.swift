//
//  HandRankCalculator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/23/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandRankComparator<HandRankType: HandRank> {
    
    static func compareHands(inout handsOdds: [HandOdds], orderedBoards: [OrderedCards]) -> Bool {
        typealias HandData = (handRank: HandRankType, handOddsIndex: Int)
        var handsData: [HandData] = []
        for (index, orderedBoard) in orderedBoards.enumerate() {
            if let handRank = HandRankType(orderedCards: orderedBoard) {
                handsData.append((handRank: handRank, handOddsIndex: index))
            }
        }
        
        guard handsData.count != 0 else { return false }
        
        var winningHandsData: [HandData] = []
        for handData in handsData {
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
            for winningHandData in winningHandsData {
                handsOdds[winningHandData.handOddsIndex].winningCombinationsCount += 1.0 / Double(winningHandsData.count)
            }
        }
        
        return true
    }
}