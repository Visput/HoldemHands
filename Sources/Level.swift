//
//  Level.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import ObjectMapper

struct Level: Equatable, Mappable {
    
    private(set) var numberOfHands: Int!
    private(set) var chipsToUnlock: Int64!
    private(set) var chipsPerWin: Int64!
    private(set) var winsInRowToDoubleChips: Int!
    private(set) var name: String!
    private(set) var identifier: Int!
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        numberOfHands <- map["numberOfHands"]
        chipsToUnlock <- map["chipsToUnlock"]
        chipsPerWin <- map["chipsPerWin"]
        winsInRowToDoubleChips <- map["winsInRowToDoubleChips"]
        name <- map["name"]
        identifier <- map["identifie"]
    }
}

func == (lhs: Level, rhs: Level) -> Bool {
    return lhs.identifier == rhs.identifier
}
