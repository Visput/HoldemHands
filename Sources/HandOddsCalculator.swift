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
    private(set) var winningHandsOdds: [HandOdds]!
    
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
        let numberOfThreads = 1
        
        let boardSize = 5
        let deckSize = 52
        let handSize = 2
        let numberOfCombinations = numberOfBoardsWithSize(boardSize, inDeckOfSize: deckSize - (self.hands.count * handSize))
        
        var handsOdds = [HandOdds]()
        for hand in hands {
            handsOdds.append(HandOdds(hand: hand, totalCombinationsCount: numberOfCombinations))
        }
        
        let group = dispatch_group_create()
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        for _ in 0 ..< numberOfThreads {
            dispatch_group_async(group, queue, {
                
                var subHandsOdds = [HandOdds]()
                for hand in self.hands {
                    subHandsOdds.append(HandOdds(hand: hand))
                }

                var handRankComparator = HandRankComparator(numberOfHands: self.hands.count)
                var boardCards = QuickArray<Card>(5)
                var iterationHandler: () -> Void = {
                    handRankComparator.compareHands(&handsOdds, boardCards: &boardCards)
                }
                
                self.iterateDeckCards(&self.deck.cards,
                    fromIndex: 0,
                    toIndex: self.deck.cards.count - boardSize,
                    boardCards: &boardCards,
                    iterationHandler: &iterationHandler)
                
                handRankComparator.destroy()
                boardCards.destroy()
                
                for (index, subHandOdds) in subHandsOdds.enumerate() {
                    handsOdds[index].winningCombinationsCount += subHandOdds.winningCombinationsCount
                }
            })
        }
        
        dispatch_group_notify(group, queue, {
            
            self.handsOdds = handsOdds
            self.winningHandsOdds = []
            
            for handOdds in handsOdds {
                if self.winningHandsOdds.count == 0 {
                    self.winningHandsOdds.append(handOdds)
                    
                } else if self.winningHandsOdds.last!.winningCombinationsCount == handOdds.winningCombinationsCount {
                    self.winningHandsOdds.append(handOdds)
                    
                } else if self.winningHandsOdds.last!.winningCombinationsCount < handOdds.winningCombinationsCount {
                    self.winningHandsOdds.removeAll()
                    self.winningHandsOdds.append(handOdds)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion()
            })
        })
    }
    
    func isWinningHandOdds(handOdds: HandOdds) -> Bool {
        return winningHandsOdds.indexOf(handOdds) != nil
    }
}

extension HandOddsCalculator {
    
    private func iterateDeckCards(inout deckCards: [Card],
        fromIndex: Int,
        toIndex: Int,
        inout boardCards: QuickArray<Card>,
        inout iterationHandler: () -> Void) {
            
            if toIndex < deckCards.count {
                for index in fromIndex ... toIndex {
                    boardCards.append(deckCards[index])
                    
                    iterateDeckCards(&deckCards,
                        fromIndex: index + 1,
                        toIndex: toIndex + 1,
                        boardCards: &boardCards,
                        iterationHandler: &iterationHandler)
                    
                    boardCards.removeLast()
                }
            } else {
                iterationHandler()
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
