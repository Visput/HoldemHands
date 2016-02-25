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
    
    func testStraightRank1() {
        let boardCards = [
            Card(rank: .Ace, suit: .Diamonds),
            Card(rank: .Ace, suit: .Spades),
            Card(rank: .Ace, suit: .Clubs),
            Card(rank: .King, suit: .Hearts),
            Card(rank: .Ten, suit: .Spades)
        ]
        
        let hand = Hand(firstCard: Card(rank: .Queen, suit: .Hearts), secondCard: Card(rank: .Jack, suit: .Hearts))
        
        let orderedCards = OrderedCards(hand: hand, boardCards: boardCards)
        XCTAssertNotNil(StraightRank(orderedCards: orderedCards))
    }
    
    func testStraightRank2() {
        let boardCards = [
            Card(rank: .Ace, suit: .Spades),
            Card(rank: .King, suit: .Hearts),
            Card(rank: .Ten, suit: .Diamonds),
            Card(rank: .Ten, suit: .Clubs),
            Card(rank: .Ten, suit: .Spades)
        ]
        
        let hand = Hand(firstCard: Card(rank: .Queen, suit: .Hearts), secondCard: Card(rank: .Jack, suit: .Hearts))
        
        let orderedCards = OrderedCards(hand: hand, boardCards: boardCards)
        XCTAssertNotNil(StraightRank(orderedCards: orderedCards))
    }
    
    func testStraightRank3() {
        let boardCards = [
            Card(rank: .Ace, suit: .Spades),
            Card(rank: .Ace, suit: .Hearts),
            Card(rank: .Five, suit: .Diamonds),
            Card(rank: .Two, suit: .Clubs),
            Card(rank: .Two, suit: .Spades)
        ]
        
        let hand = Hand(firstCard: Card(rank: .Four, suit: .Hearts), secondCard: Card(rank: .Three, suit: .Hearts))
        
        let orderedCards = OrderedCards(hand: hand, boardCards: boardCards)
        XCTAssertNotNil(StraightRank(orderedCards: orderedCards))
    }
    
    func testStraightRank4() {
        let boardCards = [
            Card(rank: .Ace, suit: .Spades),
            Card(rank: .Ace, suit: .Hearts),
            Card(rank: .Seven, suit: .Diamonds),
            Card(rank: .Five, suit: .Clubs),
            Card(rank: .Four, suit: .Spades)
        ]
        
        let hand = Hand(firstCard: Card(rank: .Three, suit: .Hearts), secondCard: Card(rank: .Two, suit: .Hearts))
        
        let orderedCards = OrderedCards(hand: hand, boardCards: boardCards)
        XCTAssertNotNil(StraightRank(orderedCards: orderedCards))
    }
    
    func testStraightRank5() {
        let boardCards = [
            Card(rank: .Ace, suit: .Spades),
            Card(rank: .Ace, suit: .Hearts),
            Card(rank: .Five, suit: .Diamonds),
            Card(rank: .Four, suit: .Clubs),
            Card(rank: .Three, suit: .Spades)
        ]
        
        let hand = Hand(firstCard: Card(rank: .Two, suit: .Spades), secondCard: Card(rank: .Two, suit: .Hearts))
        
        let orderedCards = OrderedCards(hand: hand, boardCards: boardCards)
        XCTAssertNotNil(StraightRank(orderedCards: orderedCards))
    }
    
    func testStraightFlushRank1() {
        let boardCards = [
            Card(rank: .Ace, suit: .Spades),
            Card(rank: .Ace, suit: .Hearts),
            Card(rank: .Five, suit: .Spades),
            Card(rank: .Four, suit: .Spades),
            Card(rank: .Three, suit: .Spades)
        ]
        
        let hand = Hand(firstCard: Card(rank: .Two, suit: .Hearts), secondCard: Card(rank: .Two, suit: .Spades))
        
        let orderedCards = OrderedCards(hand: hand, boardCards: boardCards)
        XCTAssertNotNil(StraightFlushRank(orderedCards: orderedCards))
    }
    
    func testOddsCalculator1() {
        let firstHand = Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts))
        let secondHand = Hand(firstCard: Card(rank: .Nine, suit: .Spades), secondCard: Card(rank: .Five, suit: .Clubs))
        
        var deck = Deck()
        deck.removeHand(firstHand)
        deck.removeHand(secondHand)
        
        var oddsCalculator = OddsCalculator(hands: [firstHand, secondHand], deck: deck)
        oddsCalculator.calculateOdds()
        
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[0].winningProbability(), 65.27, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[0].tieProbability(), 0.38, accuracy: 0.01)
        
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[1].winningProbability(), 34.35, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[1].tieProbability(), 0.38, accuracy: 0.01)
    }
    
    func testOddsCalculator2() {
        let firstHand = Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts))
        let secondHand = Hand(firstCard: Card(rank: .Ace, suit: .Spades), secondCard: Card(rank: .King, suit: .Clubs))
        
        var deck = Deck()
        deck.removeHand(firstHand)
        deck.removeHand(secondHand)
        
        var oddsCalculator = OddsCalculator(hands: [firstHand, secondHand], deck: deck)
        oddsCalculator.calculateOdds()
        
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[0].winningProbability(), 2.17, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[0].tieProbability(), 95.65, accuracy: 0.01)
        
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[1].winningProbability(), 2.17, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[1].tieProbability(), 95.65, accuracy: 0.01)
    }
    
}
