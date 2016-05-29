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
        let leftValue = self.applyPrecision(precision)
        let rightValue = value.applyPrecision(precision)
        let difference = leftValue - rightValue
        
        if abs(difference) < precision {
            return .OrderedSame
        } else if difference < 0 {
            return .OrderedAscending
        } else {
            return .OrderedDescending
        }
    }
    
    private func applyPrecision(precision: Double) -> Double {
        let precisionCoefficient = 1.0 / precision
        return round(self * precisionCoefficient) / precisionCoefficient
    }
}
