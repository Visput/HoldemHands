//
//  OddsCalculator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

class OddsCalculator {
    
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
        dispatch_async(dispatch_queue_create("odds_calculation", nil), {
            let boardSize = 5
            let deckSize = 52
            let handSize = 2
            let numberOfCombinations = self.numberOfBoardsWithSize(boardSize, inDeckOfSize: deckSize - (self.hands.count * handSize))
            
            var handsOdds = [HandOdds]()
            for hand in self.hands {
                handsOdds.append(HandOdds(hand: hand, totalCombinationsCount: numberOfCombinations))
            }
            
            var straightFlushComparator = HandRankComparator<StraightFlushRank>()
            var fourOfKindComparator = HandRankComparator<FourOfKindRank>()
            var fullHouseComparator = HandRankComparator<FullHouseRank>()
            var flushComparator = HandRankComparator<FlushRank>()
            var straightComparator = HandRankComparator<StraightRank>()
            var threeOfKindComparator = HandRankComparator<ThreeOfKindRank>()
            var twoPairsComparator = HandRankComparator<TwoPairsRank>()
            var pairComparator = HandRankComparator<PairRank>()
            var highCardComparator = HandRankComparator<HighCardRank>()
            
            var orderedBoards = QuickArray<OrderedCards>()
            
            self.iterateBoardsOfSize(boardSize, inDeck: self.deck, iterationHandler: { boardCards in
                
                orderedBoards.removeAll()
                for handOdds in handsOdds {
                    orderedBoards.append(OrderedCards(hand: handOdds.hand, boardCards: boardCards))
                }
                
                guard !straightFlushComparator.compareHands(&handsOdds, orderedBoards: &orderedBoards) else { return }
                guard !fourOfKindComparator.compareHands(&handsOdds, orderedBoards: &orderedBoards) else { return }
                guard !fullHouseComparator.compareHands(&handsOdds, orderedBoards: &orderedBoards) else { return }
                guard !flushComparator.compareHands(&handsOdds, orderedBoards: &orderedBoards) else { return }
                guard !straightComparator.compareHands(&handsOdds, orderedBoards: &orderedBoards) else { return }
                guard !threeOfKindComparator.compareHands(&handsOdds, orderedBoards: &orderedBoards) else { return }
                guard !twoPairsComparator.compareHands(&handsOdds, orderedBoards: &orderedBoards) else { return }
                guard !pairComparator.compareHands(&handsOdds, orderedBoards: &orderedBoards) else { return }
                guard !highCardComparator.compareHands(&handsOdds, orderedBoards: &orderedBoards) else { return }
            })
            
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

extension OddsCalculator {
    
    private func iterateBoardsOfSize(boardSize: Int,
        inDeck deck: Deck,
        iterationHandler: (boardCards: QuickArray<Card>) -> Void) {
            
            var emptyBoard = QuickArray<Card>()
            
            iterateDeckCards(deck.cards,
                fromIndex: 0,
                toIndex: deck.cards.count - boardSize,
                boardCards: &emptyBoard,
                iterationHandler: iterationHandler)
    }
    
    private func iterateDeckCards(deckCards: [Card],
        fromIndex: Int,
        toIndex: Int,
        inout boardCards: QuickArray<Card>,
        iterationHandler: (boardCards: QuickArray<Card>) -> Void) {
            
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