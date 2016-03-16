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
    private(set) var leaderboardID: String!
    
    init?(_ map: Map) {}
    
    mutating func mapping(map: Map) {
        let transformOfInt64 = TransformOf<Int64, NSNumber>(fromJSON: { $0?.longLongValue }, toJSON: { $0.map { NSNumber(longLong: $0) } })
        
        numberOfHands <- map["number_of_hands"]
        chipsToUnlock <- (map["chips_to_unlock"], transformOfInt64)
        chipsPerWin <- (map["chips_per_win"], transformOfInt64)
        winsInRowToDoubleChips <- map["wins_in_row_to_double_chips"]
        name <- map["name"]
        identifier <- map["identifier"]
        leaderboardID <- map["leaderboard_id"]
    }
}

func == (lhs: Level, rhs: Level) -> Bool {
    return lhs.identifier == rhs.identifier
}
