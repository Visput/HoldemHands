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
    var chipsTimeBonus: Int64!
    var handsOdds: [HandOdds]?
    
    private(set) var hands: [Hand]!
    
    var completed: Bool {
        return selectedHand != nil
    }
    
    var won: Bool? {
        guard let selectedHand = selectedHand else { return nil }
        return handsOdds?.filter { $0.hand == selectedHand }.first!.wins
    }
    
    var tieProbability: Double? {
        return handsOdds?.first?.tieProbability()
    }
    
    init(level: Level) {
        var deck = Deck()
        var hands = [Hand]()
        for _ in 0 ..< level.numberOfHands {
            hands.append(deck.nextHand())
        }
        self.hands = hands
        self.chipsTimeBonus = level.maxChipsTimeBonus
    }
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        hands <- map["hands"]
        chipsTimeBonus <- (map["time_bonus"], Int64Transform())
    }
}
