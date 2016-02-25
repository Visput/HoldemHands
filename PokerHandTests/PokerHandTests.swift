//
//  PokerHandTests.swift
//  PokerHandTests
//
//  Created by Uladzimir Papko on 2/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import XCTest
@testable import PokerHand

class PokerHandTests: XCTestCase {
    
    func testOrderedCards() {
        let boardCards = [
            Card(rank: .Ace, suit: .Diamonds),
            Card(rank: .Ace, suit: .Spades),
            Card(rank: .Ace, suit: .Hearts),
            Card(rank: .Ace, suit: .Clubs),
            Card(rank: .Ten, suit: .Spades)
        ]
        
        let hand = Hand(firstCard: Card(rank: .Jack, suit: .Hearts), secondCard: Card(rank: .Seven, suit: .Hearts))
        
        let orderedCards = OrderedCards(hand: hand, boardCards: boardCards)
        let expectedCards = [
            Card(rank: .Ace, suit: .Diamonds),
            Card(rank: .Ace, suit: .Spades),
            Card(rank: .Ace, suit: .Hearts),
            Card(rank: .Ace, suit: .Clubs),
            Card(rank: .Jack, suit: .Hearts),
            Card(rank: .Ten, suit: .Spades),
            Card(rank: .Seven, suit: .Hearts)
        ]
        
        XCTAssertEqual(orderedCards.cards, expectedCards)
    }
    
    func testOddsCalculator() {
        var deck = Deck()
        let firstHand = Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts))
        let secondHand = Hand(firstCard: Card(rank: .Nine, suit: .Spades), secondCard: Card(rank: .Five, suit: .Clubs))
        deck.removeHand(firstHand)
        deck.removeHand(secondHand)
        
        var oddsCalculator = OddsCalculator(hands: [firstHand, secondHand], deck: deck)
        oddsCalculator.calculateOdds()
        
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[0].winningProbability(), 65.27, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[0].tieProbability(), 0.38, accuracy: 0.01)
        
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[1].winningProbability(), 34.35, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[1].tieProbability(), 0.38, accuracy: 0.01)
    }
    
}
