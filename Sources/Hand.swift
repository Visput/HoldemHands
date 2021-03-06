//
//  File.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/17/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct Hand: Equatable {
    
    let firstCard: Card
    let secondCard: Card
}

@inline(__always) func == (lhs: Hand, rhs: Hand) -> Bool {
    return lhs.firstCard == rhs.firstCard && lhs.secondCard == rhs.secondCard
}
