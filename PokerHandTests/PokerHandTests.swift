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
    
}
