//
//  Double+Chips.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

extension Double {
    
    var formattedChipsCountString: String {
        return NSString(format: "%.0f$", self) as String
    }
}
