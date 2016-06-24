//
//  Round.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 6/7/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import ObjectMapper

struct Round: Mappable {
    
    var selectedHand: Hand?
    private(set) var oddsCalculator: HandOddsCalculator!
    
    var hands: [Hand] {
        return oddsCalculator.hands
    }
    
    var completed: Bool {
        return selectedHand != nil
    }
    
    var won: Bool? {
        guard let selectedHand = selectedHand else { return nil }
        return oddsCalculator.oddsForHand(selectedHand)!.wins
    }
    
    init(level: Level) {
        var deck = Deck()
        var hands = [Hand]()
        for _ in 0 ..< level.numberOfHands {
            hands.append(deck.nextHand())
        }
        self.oddsCalculator = HandOddsCalculator(hands: hands)
    }
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        oddsCalculator <- map["calculator"]
    }
}
