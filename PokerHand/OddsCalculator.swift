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
    
    mutating func calculateOdds() {
        let boardSize = 5
        let deckSize = 52
        let handSize = 2
        let numberOfCombinations = numberOfBoardsWithSize(boardSize, inDeckOfSize: deckSize - (hands.count * handSize))
        
        var handsOdds = [HandOdds]()
        for hand in hands {
            handsOdds.append(HandOdds(hand: hand, totalCombinationsCount: numberOfCombinations))
        }
        
        iterateBoardsOfSize(boardSize, inDeck: deck, iterationHandler: { boardCards in
            var orderedBoards = [OrderedCards]()
            for handOdds in handsOdds {
                orderedBoards.append(OrderedCards(hand: handOdds.hand, boardCards: boardCards))
            }
            
            guard !HandRankComparator<StraightFlushRank>.compareHands(&handsOdds, orderedBoards: orderedBoards) else { return }
            guard !HandRankComparator<FourOfKindRank>.compareHands(&handsOdds, orderedBoards: orderedBoards) else { return }
            guard !HandRankComparator<FullHouseRank>.compareHands(&handsOdds, orderedBoards: orderedBoards) else { return }
            guard !HandRankComparator<FlushRank>.compareHands(&handsOdds, orderedBoards: orderedBoards) else { return }
            guard !HandRankComparator<StraightRank>.compareHands(&handsOdds, orderedBoards: orderedBoards) else { return }
            guard !HandRankComparator<ThreeOfKindRank>.compareHands(&handsOdds, orderedBoards: orderedBoards) else { return }
            guard !HandRankComparator<TwoPairsRank>.compareHands(&handsOdds, orderedBoards: orderedBoards) else { return }
            guard !HandRankComparator<PairRank>.compareHands(&handsOdds, orderedBoards: orderedBoards) else { return }
            guard !HandRankComparator<HighCardRank>.compareHands(&handsOdds, orderedBoards: orderedBoards) else { return }
        })
        
        self.handsOdds = handsOdds
        
        winningHandsOdds = []
        
        for handOdds in handsOdds {
            if winningHandsOdds.count == 0 {
                winningHandsOdds.append(handOdds)
                
            } else if winningHandsOdds.last!.totalWinningCombinationsCount() == handOdds.totalWinningCombinationsCount() {
                winningHandsOdds.append(handOdds)
                
            } else if winningHandsOdds.last!.totalWinningCombinationsCount() < handOdds.totalWinningCombinationsCount() {
                winningHandsOdds.removeAll()
                winningHandsOdds.append(handOdds)
            }
        }
    }
    
    func isWinningHandOdds(handOdds: HandOdds) -> Bool {
        return winningHandsOdds.indexOf(handOdds) != nil
    }
}

extension OddsCalculator {
    
    private func iterateBoardsOfSize(boardSize: Int,
        inDeck deck: Deck,
        iterationHandler: (boardCards: [Card]) -> Void) {
            
            var emptyBoard = [Card]()
            
            iterateDeckCards(deck.cards,
                fromIndex: 0,
                toIndex: deck.cards.count - boardSize,
                boardCards: &emptyBoard,
                iterationHandler: iterationHandler)
    }
    
    private func iterateDeckCards(deckCards: [Card],
        fromIndex: Int,
        toIndex: Int,
        inout boardCards: [Card],
        iterationHandler: (boardCards: [Card]) -> Void) {
            
            if toIndex < deckCards.count {
                for index in fromIndex ... toIndex {
                    boardCards.append(deckCards[index])
                    
                    iterateDeckCards(deckCards,
                        fromIndex: index + 1,
                        toIndex: toIndex + 1,
                        boardCards: &boardCards,
                        iterationHandler: iterationHandler)
                    
                    boardCards.removeLast()
                }
            } else {
                iterationHandler(boardCards: boardCards)
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