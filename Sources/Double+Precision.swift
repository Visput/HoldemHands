//
//  Double+Precision.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

extension Double {
    
    func compare(value: Double, precision: Double) -> NSComparisonResult {
        let precisionCoefficient = 1.0 / precision
        
        let leftValue = round(self * precisionCoefficient)
        let rightValue = round(value * precisionCoefficient)
        let difference = leftValue - rightValue
        
        if abs(difference) < 1 {
            return .OrderedSame
        } else if difference < 0 {
            return .OrderedAscending
        } else {
            return .OrderedDescending
        }
    }
}
