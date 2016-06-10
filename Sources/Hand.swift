//
//  File.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/17/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import ObjectMapper

struct Hand: Equatable, Mappable {
    
    private(set) var firstCard: Card!
    private(set) var secondCard: Card!
    
    @inline(__always) init(firstCard: Card, secondCard: Card) {
        self.firstCard = firstCard
        self.secondCard = secondCard
    }
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        firstCard <- map["first"]
        secondCard <- map["second"]
    }
}

@inline(__always) func == (lhs: Hand, rhs: Hand) -> Bool {
    return lhs.firstCard == rhs.firstCard && lhs.secondCard == rhs.secondCard
}
