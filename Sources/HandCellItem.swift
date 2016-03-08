//
//  HandCellItem.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/19/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct HandCellItem {
    
    let handOdds: HandOdds?
    let needsShowOdds: Bool!
    let isSuccessSate: Bool?
    
    init(handOdds: HandOdds?, needsShowOdds: Bool, isSuccessSate: Bool?) {
        self.handOdds = handOdds
        self.needsShowOdds = needsShowOdds
        self.isSuccessSate = isSuccessSate
    }
}
