//
//  PokerHandTests.swift
//  PokerHandTests
//
//  Created by Uladzimir Papko on 2/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import XCTest
@testable import PokerHand

/// Note: Expected results for odds calculator were provided by online calculator: 
/// http://www.cardplayer.com/poker-tools/odds-calculator/texas-holdem

class PokerHandTests: XCTestCase {
    
    func testOrderedCards1() {
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
        let hands = [
            Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Nine, suit: .Spades), secondCard: Card(rank: .Five, suit: .Clubs))
        ]
        
        let oddsResults: [OddsResult] = [
            (win: 65.27, tie: 0.38),
            (win: 34.35, tie: 0.38)
        ]
        
        testOddsCalculatorWithHands(hands, expectedOddsResults: oddsResults)
    }
    
    func testOddsCalculator2() {
        let hands = [
            Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Ace, suit: .Spades), secondCard: Card(rank: .King, suit: .Clubs))
        ]
        
        let oddsResults: [OddsResult] = [
            (win: 2.17, tie: 95.65),
            (win: 2.17, tie: 95.65)
        ]
        
        testOddsCalculatorWithHands(hands, expectedOddsResults: oddsResults)
    }
    
    func testOddsCalculator3() {
        let hands = [
            Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Nine, suit: .Spades), secondCard: Card(rank: .Five, suit: .Clubs)),
            Hand(firstCard: Card(rank: .King, suit: .Spades), secondCard: Card(rank: .Two, suit: .Clubs))
        ]
       
        let oddsResults: [OddsResult] = [
            (win: 50.62, tie: 1.20),
            (win: 35.04, tie: 0.42),
            (win: 13.13, tie: 1.20)
        ]
        
        testOddsCalculatorWithHands(hands, expectedOddsResults: oddsResults)
    }
    
    func testOddsCalculator4() {
        let hands = [
            Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Nine, suit: .Spades), secondCard: Card(rank: .Five, suit: .Clubs)),
            Hand(firstCard: Card(rank: .King, suit: .Diamonds), secondCard: Card(rank: .Two, suit: .Clubs)),
            Hand(firstCard: Card(rank: .Three, suit: .Hearts), secondCard: Card(rank: .Two, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Ten, suit: .Spades), secondCard: Card(rank: .Ten, suit: .Clubs)),
            Hand(firstCard: Card(rank: .Ten, suit: .Diamonds), secondCard: Card(rank: .Nine, suit: .Clubs)),
            Hand(firstCard: Card(rank: .Queen, suit: .Spades), secondCard: Card(rank: .Seven, suit: .Spades)),
            Hand(firstCard: Card(rank: .Six, suit: .Spades), secondCard: Card(rank: .Six, suit: .Clubs)),
            Hand(firstCard: Card(rank: .Queen, suit: .Hearts), secondCard: Card(rank: .Jack, suit: .Clubs)),
            Hand(firstCard: Card(rank: .Ace, suit: .Spades), secondCard: Card(rank: .Four, suit: .Clubs))
        ]
        
        let oddsResults: [OddsResult] = [
            (win: 11.90, tie: 1.09),
            (win: 5.82, tie: 0.83),
            (win: 2.59, tie: 0.95),
            (win: 14.04, tie: 0.47),
            (win: 10.00, tie: 1.76),
            (win: 6.99, tie: 2.51),
            (win: 10.63, tie: 0.74),
            (win: 17.88, tie: 0.07),
            (win: 8.72, tie: 0.74),
            (win: 6.84, tie: 0.61)
        ]
        
        testOddsCalculatorWithHands(hands, expectedOddsResults: oddsResults)
    }
}

extension PokerHandTests {
    
    typealias OddsResult = (win: Double, tie: Double)
    
    private func testOddsCalculatorWithHands(hands: [Hand], expectedOddsResults: [OddsResult]) {
        var deck = Deck()
        for hand in hands {
            deck.removeHand(hand)
        }
        
        var oddsCalculator = OddsCalculator(hands: hands, deck: deck)
        oddsCalculator.calculateOdds()
        
        for index in 0 ..< hands.count {
            XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[index].winningProbability(),
                expectedOddsResults[index].win,
                accuracy: 0.01)
            
            XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[index].tieProbability(),
                expectedOddsResults[index].tie,
                accuracy: 0.01)
        }
    }
}
