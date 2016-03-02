//
//  HandOddsCalculator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

final class HandOddsCalculator {
    
    private(set) var hands: [Hand]
    private(set) var deck: Deck
    private(set) var handsOdds: [HandOdds]!
    
    init(numberOfHands: Int) {
        deck = Deck()
        hands = [Hand]()
        for _ in 0 ..< numberOfHands {
            hands.append(deck.nextHand())
        }
        deck.sortCards()
    }
    
    init(hands: [Hand], deck: Deck) {
        self.hands = hands
        self.deck = deck
        self.deck.sortCards()
    }
    
    func calculateOdds(completion: () -> Void) {
        let boardSize = 5
        let deckSize = 52
        let handSize = 2
        let numberOfCombinations = numberOfBoardsWithSize(boardSize, inDeckOfSize: deckSize - (hands.count * handSize))
        
        var handsOdds = [HandOdds]()
        for hand in hands {
            handsOdds.append(HandOdds(hand: hand, totalCombinationsCount: numberOfCombinations))
        }
        
        let group = dispatch_group_create()
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let iterationIndexes = [(0, 5), (6, self.deck.cards.count - boardSize)]
        
        for index in 0 ..< iterationIndexes.count {
            dispatch_group_async(group, queue, {
                
                var subHandsOdds = [HandOdds]()
                for hand in self.hands {
                    subHandsOdds.append(HandOdds(hand: hand))
                }

                var handRankComparator = HandRankComparator(numberOfHands: self.hands.count)
                var boardCards = QuickArray<Card>(5)
                
                self.iterateDeckCards(&self.deck.cards,
                    boardCards: &boardCards,
                    handRankComparator: &handRankComparator,
                    handsOdds: &subHandsOdds,
                    minIndex: iterationIndexes[index].0,
                    maxIndex: iterationIndexes[index].1,
                    toIndex: self.deck.cards.count - boardSize)
                
                handRankComparator.destroy()
                boardCards.destroy()
                
                for (index, subHandOdds) in subHandsOdds.enumerate() {
                    handsOdds[index].winningCombinationsCount += subHandOdds.winningCombinationsCount
                }
            })
        }
        
        dispatch_group_notify(group, queue, {
            
            // Calculate winning hands.
            self.handsOdds = handsOdds
            var winningHandsOddsIndexes = [Int]()
            
            for index in 0 ..< self.handsOdds.count {
                let handOdds = self.handsOdds[index]
                
                if winningHandsOddsIndexes.count == 0 {
                    winningHandsOddsIndexes.append(index)
                    
                } else if handsOdds[winningHandsOddsIndexes.last!].winningCombinationsCount == handOdds.winningCombinationsCount {
                    winningHandsOddsIndexes.append(index)
                    
                } else if handsOdds[winningHandsOddsIndexes.last!].winningCombinationsCount < handOdds.winningCombinationsCount {
                    winningHandsOddsIndexes.removeAll()
                    winningHandsOddsIndexes.append(index)
                }
            }
            
            for index in winningHandsOddsIndexes {
                self.handsOdds[index].wins = true
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion()
            })
        })
    }
    
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
}
