//
//  Progress.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

protocol Progress {
    
    var maxWinsCountInRow: Int! { get }
    var winsCount: Int! { get }
    var lossesCount: Int! { get }
    var rank: Int? { get }
    
    var chipsCount: Int64 { get }
    var leaderboardID: String { get }
    
    var winPercent: Double { get }
    var handsCount: Int { get }
    var identifier: String { get }
    var locked: Bool! { get }
}

extension Progress {
    
    var winPercent: Double {
        return Double(100 * winsCount) / Double(winsCount + lossesCount)
    }
    
    var handsCount: Int {
        return winsCount + lossesCount
    }
}
