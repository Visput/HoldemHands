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
    
    func title() -> String?
}
