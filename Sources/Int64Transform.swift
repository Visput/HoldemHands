//
//  Int64Transform.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 6/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import ObjectMapper

final class Int64Transform: TransformType {
    
    typealias Object = Int64
    typealias JSON = NSNumber
    
    init() {}
    
    func transformFromJSON(value: AnyObject?) -> Int64? {
        return (value as? NSNumber)?.longLongValue
    }
    
    func transformToJSON(value: Int64?) -> NSNumber? {
        if let value = value {
            return NSNumber(longLong: value)
        } else {
            return nil
        }
    }
}
