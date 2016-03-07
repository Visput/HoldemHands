//
//  HoldemHandsTests.swift
//  HoldemHandsTests
//
//  Created by Uladzimir Papko on 2/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import XCTest
@testable import HoldemHands

class HoldemHandsTests: XCTestCase {
    
    func testOddsCalculator1() {
        let hands = [
            Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Nine, suit: .Spades), secondCard: Card(rank: .Five, suit: .Clubs))
        ]
        
        let oddsResults: [OddsResult] = [
            (winProbability: 65.46, winCount: 1120951.5),
            (winProbability: 34.54, winCount: 591352.5)
        ]
        
        testOddsCalculatorWithHands(hands, expectedOddsResults: oddsResults)
    }
    
    func testOddsCalculator2() {
        let hands = [
            Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Ace, suit: .Spades), secondCard: Card(rank: .King, suit: .Clubs))
        ]
        
        let oddsResults: [OddsResult] = [
            (winProbability: 50.0, winCount: 856152.0),
            (winProbability: 50.0, winCount: 856152.0)
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
            (winProbability: 51.15, winCount: 701202.17),
            (winProbability: 35.18, winCount: 482273.67),
            (winProbability: 13.66, winCount: 187278.17)
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
            Hand(firstCard: Card(rank: .Six, suit: .Spades), secondCard: Card(rank: .Six, suit: .Clubs))
        ]
        
        let oddsResults: [OddsResult] = [
            (winProbability: 18.13, winCount: 68359.25),
            (winProbability: 5.70, winCount: 21470.75),
            (winProbability: 2.70, winCount: 10181.25),
            (winProbability: 14.94, winCount: 56313.75),
            (winProbability: 14.92, winCount: 56259.75),
            (winProbability: 9.01, winCount: 33976.75),
            (winProbability: 17.48, winCount: 65881.75),
            (winProbability: 17.12, winCount: 64548.75)
        ]
        
        testOddsCalculatorWithHands(hands, expectedOddsResults: oddsResults)
    }
}

extension HoldemHandsTests {
    
    typealias OddsResult = (winProbability: Double, winCount: Double)
    
    private func testOddsCalculatorWithHands(hands: [Hand], expectedOddsResults: [OddsResult]) {
        var deck = Deck()
        for hand in hands {
            deck.removeHand(hand)
        }
        
        let calculationExpecation = expectationWithDescription("calculationExpecation")
        
        let oddsCalculator = HandOddsCalculator(hands: hands, deck: deck)
        oddsCalculator.calculateOdds({ handsOdds in
            for index in 0 ..< hands.count {
                XCTAssertEqualWithAccuracy(handsOdds[index].winningProbability(),
                    expectedOddsResults[index].winProbability,
                    accuracy: 0.01)
                
                XCTAssertEqualWithAccuracy(handsOdds[index].winningCombinationsCount,
                    expectedOddsResults[index].winCount,
                    accuracy: 0.01)
            }
            calculationExpecation.fulfill()
        })
        
        waitForExpectationsWithTimeout(300, handler: nil)
    }
}
