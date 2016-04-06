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
        formatter.currencySymbol = "$"
        formatter.numberStyle = .CurrencyStyle
        formatter.maximumFractionDigits = 0
        var formattedString = formatter.stringFromNumber(NSNumber(longLong: self))!
        // Replace 0 with O to remove separator from oval.
        formattedString = formattedString.stringByReplacingOccurrencesOfString("0", withString: "O")
        
        return formattedString
    }
}
