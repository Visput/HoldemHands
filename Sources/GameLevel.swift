//
//  GameLevel.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct GameLevel: Equatable {
    
    let numberOfHands: Int
    let chipsToUnlock: Double
    let chipsPerWin: Double
    let winsInRowToDoubleChips: Int
    let name: String
    let identifier: Int
}

func == (lhs: GameLevel, rhs: GameLevel) -> Bool {
    return lhs.identifier == rhs.identifier
}
