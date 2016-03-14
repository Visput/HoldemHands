//
//  Int64+Chips.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

extension Int64 {
    
    var formattedChipsCountString: String {
        return NSString(format: "%lld$", self) as String
    }
}
