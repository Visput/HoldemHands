//
//  Progress.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

protocol Progress {
    
    var maxNumberOfWinsInRow: Int { get }
    var numberOfWins: Int { get }
    var numberOfLosses: Int { get }
    var chipsCount: Double { get }
    
    var title: String? { get }
    var winPercent: Double { get }
    var handsCount: Int { get }
}

extension Progress {
    
    var winPercent: Double {
        return Double(100 * numberOfWins) / Double(numberOfWins + numberOfLosses)
    }
    
    var handsCount: Int {
        return numberOfWins + numberOfLosses
    }
}
