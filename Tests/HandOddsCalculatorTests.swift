//
//  HandOddsCalculatorTests.swift
//  HoldemHandsTests
//
//  Created by Uladzimir Papko on 2/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import XCTest
@testable import HoldemHands

class HandOddsCalculatorTests: XCTestCase {
    
    func testOddsCalculator1() {
        let hands = [
            Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Nine, suit: .Spades), secondCard: Card(rank: .Five, suit: .Clubs))
        ]
        
        let oddsResults: [OddsResult] = [
            (winProbability: 65.46, totalWinCount: 1120951.5),
            (winProbability: 34.54, totalWinCount: 591352.5)
        ]
        
        testOddsCalculatorWithHands(hands, expectedOddsResults: oddsResults)
    }
    
    func testOddsCalculator2() {
        let hands = [
            Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Ace, suit: .Spades), secondCard: Card(rank: .King, suit: .Clubs))
        ]
        
        let oddsResults: [OddsResult] = [
            (winProbability: 50.0, totalWinCount: 856152.0),
            (winProbability: 50.0, totalWinCount: 856152.0)
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
            (winProbability: 51.15, totalWinCount: 701202.17),
            (winProbability: 35.18, totalWinCount: 482273.67),
            (winProbability: 13.66, totalWinCount: 187278.17)
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
            (winProbability: 18.13, totalWinCount: 68359.25),
            (winProbability: 5.70, totalWinCount: 21470.75),
            (winProbability: 2.70, totalWinCount: 10181.25),
            (winProbability: 14.94, totalWinCount: 56313.75),
            (winProbability: 14.92, totalWinCount: 56259.75),
            (winProbability: 9.01, totalWinCount: 33976.75),
            (winProbability: 17.48, totalWinCount: 65881.75),
            (winProbability: 17.12, totalWinCount: 64548.75)
        ]
        
        testOddsCalculatorWithHands(hands, expectedOddsResults: oddsResults)
    }
    
    func testOddsCalculator5() {
        let winningHand1 = Hand(firstCard: Card(rank: .Ace, suit: .Spades), secondCard: Card(rank: .Two, suit: .Spades))
        let winningHand2 = Hand(firstCard: Card(rank: .Queen, suit: .Diamonds), secondCard: Card(rank: .Jack, suit: .Diamonds))
        let hands = [
            winningHand1,
            winningHand2,
            Hand(firstCard: Card(rank: .Nine, suit: .Diamonds), secondCard: Card(rank: .Five, suit: .Hearts)),
            Hand(firstCard: Card(rank: .Ten, suit: .Diamonds), secondCard: Card(rank: .Eight, suit: .Clubs)),
            Hand(firstCard: Card(rank: .Eight, suit: .Spades), secondCard: Card(rank: .Three, suit: .Spades)),
            Hand(firstCard: Card(rank: .King, suit: .Diamonds), secondCard: Card(rank: .Three, suit: .Diamonds)),
            Hand(firstCard: Card(rank: .Ace, suit: .Clubs), secondCard: Card(rank: .Seven, suit: .Diamonds)),
            Hand(firstCard: Card(rank: .Jack, suit: .Hearts), secondCard: Card(rank: .Six, suit: .Diamonds))
        ]
        
        var deck = Deck()
        for hand in hands {
            deck.removeHand(hand)
        }
        
        let calculationExpecation = expectationWithDescription("calculationExpecation")
        
        let oddsCalculator = HandOddsCalculator(hands: hands, deck: deck, comparisonPrecision: 0.01)
        oddsCalculator.calculateOdds({ handsOdds in
            for handOdds in handsOdds {
                if handOdds.hand == winningHand1 || handOdds.hand == winningHand2 {
                    XCTAssertTrue(handOdds.wins)
                } else {
                    XCTAssertFalse(handOdds.wins)
                }
            }
            calculationExpecation.fulfill()
        })
        
        waitForExpectationsWithTimeout(300, handler: nil)
        
    }
}

extension HandOddsCalculatorTests {
    
    typealias OddsResult = (winProbability: Double, totalWinCount: Double)
    
    private func testOddsCalculatorWithHands(hands: [Hand], expectedOddsResults: [OddsResult]) {
        var deck = Deck()
        for hand in hands {
            deck.removeHand(hand)
        }
        
        let calculationExpecation = expectationWithDescription("calculationExpecation")
        
        let oddsCalculator = HandOddsCalculator(hands: hands, deck: deck, comparisonPrecision: 0.01)
        oddsCalculator.calculateOdds({ handsOdds in
            for index in 0 ..< hands.count {
                XCTAssertEqualWithAccuracy(handsOdds[index].totalWinningProbability(),
                    expectedOddsResults[index].winProbability,
                    accuracy: 0.01)
                
                XCTAssertEqualWithAccuracy(handsOdds[index].winningCombinationsCount + handsOdds[index].tieCombinationsCount,
                    expectedOddsResults[index].totalWinCount,
                    accuracy: 0.01)
            }
            calculationExpecation.fulfill()
        })
        
        waitForExpectationsWithTimeout(300, handler: nil)
    }
}
