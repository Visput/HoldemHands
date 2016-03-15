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
        let formatter =  NSNumberFormatter()
        formatter.groupingSize = 3
        formatter.groupingSeparator = " "
        formatter.currencySymbol = "$"
        formatter.numberStyle = .CurrencyStyle
        formatter.maximumFractionDigits = 0
        return formatter.stringFromNumber(NSNumber(longLong: self))!
    }
}
