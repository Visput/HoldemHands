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
            (winProbability: 12.41, winCount: 24998.00),
            (winProbability: 6.20, winCount: 12493.5),
            (winProbability: 3.04, winCount: 6115.00),
            (winProbability: 14.25, winCount: 28686.50),
            (winProbability: 10.85, winCount: 21857.50),
            (winProbability: 8.21, winCount: 16538.00),
            (winProbability: 10.97, winCount: 22087.00),
            (winProbability: 17.88, winCount: 36024.00)
        ]
        
        testOddsCalculatorWithHands(hands, expectedOddsResults: oddsResults)
    }
}

extension PokerHandTests {
    
    typealias OddsResult = (winProbability: Double, winCount: Double)
    
    private func testOddsCalculatorWithHands(hands: [Hand], expectedOddsResults: [OddsResult]) {
        var deck = Deck()
        for hand in hands {
            deck.removeHand(hand)
        }
        
        let calculationExpecation = expectationWithDescription("calculationExpecation")
        
        let oddsCalculator = OddsCalculator(hands: hands, deck: deck)
        oddsCalculator.calculateOdds({
            for index in 0 ..< hands.count {
                XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[index].winningProbability(),
                    expectedOddsResults[index].winProbability,
                    accuracy: 0.01)
                
                XCTAssertEqualWithAccuracy(oddsCalculator.handsOdds[index].winningCombinationsCount,
                    expectedOddsResults[index].winCount,
                    accuracy: 0.01)
            }
            calculationExpecation.fulfill()
        })
        
        waitForExpectationsWithTimeout(300, handler: nil)
    }
}
