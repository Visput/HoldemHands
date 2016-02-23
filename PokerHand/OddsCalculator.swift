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
    
    mutating func calculateOdds() {
        let boardSize = 5
        let deckSize = 52
        let handSize = 2
        let numberOfCombinations = numberOfSubArraysOfSize(boardSize, inArrayOfSize: deckSize - (hands.count * handSize))
        
        var handsOdds = [HandOdds]()
        for hand in hands {
            handsOdds.append(HandOdds(hand: hand, totalCombinationsCount: numberOfCombinations))
        }
        
        let time = CFAbsoluteTimeGetCurrent()
        var count = 0
        iterateSubArraysOfSize(boardSize, inArray: deck.cards, iterationHandler: { subArray in
            count += 1
            if count == numberOfCombinations {
                print(CFAbsoluteTimeGetCurrent() - time)
            }
            
            guard !HandRankComparator<StraightFlushRank>.compareHands(&handsOdds, boardCards: subArray) else { return }
            guard !HandRankComparator<FourOfKindRank>.compareHands(&handsOdds, boardCards: subArray) else { return }
            guard !HandRankComparator<FullHouseRank>.compareHands(&handsOdds, boardCards: subArray) else { return }
            guard !HandRankComparator<FlushRank>.compareHands(&handsOdds, boardCards: subArray) else { return }
            guard !HandRankComparator<StraightRank>.compareHands(&handsOdds, boardCards: subArray) else { return }
            guard !HandRankComparator<ThreeOfKindRank>.compareHands(&handsOdds, boardCards: subArray) else { return }
            guard !HandRankComparator<TwoPairsRank>.compareHands(&handsOdds, boardCards: subArray) else { return }
            guard !HandRankComparator<PairRank>.compareHands(&handsOdds, boardCards: subArray) else { return }
            guard !HandRankComparator<HighCardRank>.compareHands(&handsOdds, boardCards: subArray) else { return }
        })
        
        self.handsOdds = handsOdds
        self.sortedHandsOdds = handsOdds.sort({ (lhs, rhs) -> Bool in
            return lhs.winningCombinationsCount > rhs.winningCombinationsCount
        })
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
    
    private func numberOfSubArraysOfSize(subArraySize: Int, inArrayOfSize arraySize: Int) -> Int {
        var result = 1
        for index in arraySize - subArraySize + 1 ... arraySize {
            result *= index
        }
        for index in 2 ... subArraySize {
            result /= index
        }
        
        return result
    }
}