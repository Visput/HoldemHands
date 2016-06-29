//
//  HandOddsCalculator.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

// swiftlint:disable function_parameter_count

final class HandOddsCalculator {
    
    private(set) var hands: [Hand]! {
        didSet {
            deck = Deck.deckByExcludingHands(hands)
            deck.sortCards()
        }
    }
    
    private(set) var deck: Deck!
    private(set) var handsOdds: [HandOdds]?
    
    /// Precision used for comapring hands winning percent.
    /// If winning percent difference is less than this value than hands will be valued as equally winning.
    /// Set precision to one-hundredth of percent.
    private let comparisonPrecision = 0.01
    
    init(hands: [Hand]) {
        self.hands = hands
        self.deck = Deck.deckByExcludingHands(hands)
        self.deck.sortCards()
    }
    
    func calculateOdds(completion: (handsOdds: [HandOdds]) -> Void) {
        let time = CFAbsoluteTimeGetCurrent()
        handsOdds = nil
        
        let boardSize = 5
        let deckSize = 52
        let handSize = 2
        let numberOfCombinations = numberOfBoardsWithSize(boardSize, inDeckOfSize: deckSize - (hands.count * handSize))
        
        let splitIndex = deckSplitIndexForNumberOfHands(hands.count)
        let iterationIndexes: [(minIdex: Int, maxIndex: Int)] = [(0, splitIndex), (splitIndex + 1, deck.cards.count - boardSize)]
    
        var newHandsOdds = [HandOdds]()
        for hand in hands {
            newHandsOdds.append(HandOdds(hand: hand,
                numberOfHands: hands.count,
                totalCombinationsCount: numberOfCombinations))
        }
        
        let group = dispatch_group_create()
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
        
        for index in 0 ..< iterationIndexes.count {
            dispatch_group_async(group, queue, {
                
                var subHandsOdds = [HandOdds]()
                for hand in self.hands {
                    subHandsOdds.append(HandOdds(hand: hand,
                        numberOfHands: self.hands.count,
                        totalCombinationsCount: numberOfCombinations))
                }

                var handRankComparator = HandRankComparator(numberOfHands: self.hands.count)
                var boardCards = QuickArray<Card>(5)
                
                self.iterateDeckCards(&self.deck.cards,
                    boardCards: &boardCards,
                    handRankComparator: &handRankComparator,
                    handsOdds: &subHandsOdds,
                    minIndex: iterationIndexes[index].minIdex,
                    maxIndex: iterationIndexes[index].maxIndex,
                    toIndex: self.deck.cards.count - boardSize)
                
                handRankComparator.destroy()
                boardCards.destroy()
                
                for (index, subHandOdds) in subHandsOdds.enumerate() {
                    newHandsOdds[index].winningCombinationsCount += subHandOdds.winningCombinationsCount
                    newHandsOdds[index].tieCombinationsCount += subHandOdds.tieCombinationsCount
                }
            })
        }
        
        dispatch_group_notify(group, queue, {
            
            // Calculate winning hands.
            self.handsOdds = newHandsOdds
            var winningHandsOddsIndexes = [Int]()
            
            for index in 0 ..< self.handsOdds!.count {
                let handOdds = self.handsOdds![index]
                
                if winningHandsOddsIndexes.count == 0 {
                    winningHandsOddsIndexes.append(index)
                } else {
                    let winningHandOdds = self.handsOdds![winningHandsOddsIndexes.last!]
                    let comparisonResult = winningHandOdds.winningProbability().compare(handOdds.winningProbability(),
                        precision: self.comparisonPrecision)
                    
                    if comparisonResult == .OrderedSame {
                        winningHandsOddsIndexes.append(index)
                    } else if comparisonResult == .OrderedAscending {
                        winningHandsOddsIndexes.removeAll()
                        winningHandsOddsIndexes.append(index)
                    }
                }
            }
            
            for index in winningHandsOddsIndexes {
                self.handsOdds![index].wins = true
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                print(CFAbsoluteTimeGetCurrent() - time)
                completion(handsOdds: self.handsOdds!)
            })
        })
    }
}

extension HandOddsCalculator {
    
    @inline(__always) private func iterateDeckCards(inout deckCards: [Card],
                                                    inout boardCards: QuickArray<Card>,
                                                    inout handRankComparator: HandRankComparator,
                                                    inout handsOdds: [HandOdds],
                                                    minIndex: Int,
                                                    maxIndex: Int,
                                                    toIndex: Int) {
        
        for index in minIndex ... maxIndex {
            boardCards.append(deckCards[index])
            
            iterateDeckCards(&deckCards,
                             boardCards: &boardCards,
                             handRankComparator: &handRankComparator,
                             handsOdds: &handsOdds,
                             fromIndex: index + 1,
                             toIndex: toIndex + 1)
            
            boardCards.removeLast()
        }
    }
    
    @inline(__always) private func iterateDeckCards(inout deckCards: [Card],
                                                    inout boardCards: QuickArray<Card>,
                                                    inout handRankComparator: HandRankComparator,
                                                    inout handsOdds: [HandOdds],
                                                    fromIndex: Int,
                                                    toIndex: Int) {
        
        if toIndex < deckCards.count {
            for index in fromIndex ... toIndex {
                boardCards.append(deckCards[index])
                
                iterateDeckCards(&deckCards,
                                 boardCards: &boardCards,
                                 handRankComparator: &handRankComparator,
                                 handsOdds: &handsOdds,
                                 fromIndex: index + 1,
                                 toIndex: toIndex + 1)
                
                boardCards.removeLast()
            }
        } else {
            handRankComparator.compareHands(&handsOdds, boardCards: &boardCards)
        }
    }
    
    private func numberOfBoardsWithSize(boardSize: Int, inDeckOfSize deckSize: Int) -> Int {
        var result = 1
        for index in deckSize - boardSize + 1 ... deckSize {
            result *= index
        }
        for index in 2 ... boardSize {
            result /= index
        }
        
        return result
    }
    
    private func deckSplitIndexForNumberOfHands(numberOfHands: Int) -> Int {
        // Below numbers were calculated empirically.
        if numberOfHands < 4 {
            return 5
        } else if numberOfHands < 7 {
            return 4
        } else if numberOfHands < 9 {
            return 3
        } else {
            return 2
        }
    }
}
