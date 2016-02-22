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
    private(set) var sortedHandsOdds: [HandOdds]!
    
    init(numberOfHands: Int) {
        deck = Deck()
        hands = [Hand]()
        for _ in 0 ..< numberOfHands {
            hands.append(deck.nextHand())
        }
    }
    
    init(hands: [Hand], deck: Deck) {
        self.hands = hands
        self.deck = deck
    }
    
    func calculateOdds() {
        for 
        guard handsOdds == nil else { return }
    }
}

extension OddsCalculator {
    
    private func compareHand(lhs: OrderedCards, withHand rhs: OrderedCards) -> NSComparisonResult  {
        return .OrderedAscending
    }
}