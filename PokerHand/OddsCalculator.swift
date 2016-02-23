//
//  OddsCalculator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct OddsCalculator {
    
    private(set) var hands: [Hand]
    private(set) var deck: Deck
    private(set) var handsOdds: [HandOdds]!
    private(set) var sortedHandsOdds: [HandOdds]!
    
    init(numberOfHands: Int) {
        deck = Deck()
        hands = [Hand]()
        for _ in 0 ..< numberOfHands {
            hands.append(deck.nextHand())
        }
    }
    
    init(hands: [Hand], deck: Deck) {
        self.hands = hands
        self.deck = deck
    }
    
    func calculateOdds() {
        let boardSize = 5
        
        iterateSubArraysOfSize(boardSize, inArray: deck.cards, iterationHandler: { subArray in
            
        })
        
        guard handsOdds == nil else { return }
    }
}

extension OddsCalculator {
    
    private func compareHand(lhs: OrderedCards, withHand rhs: OrderedCards) -> NSComparisonResult  {
        return .OrderedAscending
    }
}

extension OddsCalculator {
    
    private func iterateSubArraysOfSize(subArraySize: Int,
        inArray array: [Card],
        iterationHandler: (subArray: [Card]) -> Void) {
            
            var emptyArray = [Card]()
            
            iterateArray(array,
                fromIndex: 0,
                toIndex: array.count - subArraySize,
                subArray: &emptyArray,
                iterationHandler: iterationHandler)
    }
    
    private func iterateArray(array: [Card],
        fromIndex: Int,
        toIndex: Int,
        inout subArray: [Card],
        iterationHandler: (subArray: [Card]) -> Void) {
            
            if toIndex < array.count {
                for index in fromIndex ... toIndex {
                    subArray.append(array[index])
                    
                    iterateArray(array,
                        fromIndex: index + 1,
                        toIndex: toIndex + 1,
                        subArray: &subArray,
                        iterationHandler: iterationHandler)
                    
                    subArray.removeLast()
                }
            } else {
                iterationHandler(subArray: subArray)
            }
    }
}