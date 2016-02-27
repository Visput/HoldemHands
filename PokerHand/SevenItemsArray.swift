//
//  SevenItemsArray.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/26/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct SevenItemsArray<ItemType> {
    
    private(set) var itemOne: ItemType?
    private(set) var itemTwo: ItemType?
    private(set) var itemThree: ItemType?
    private(set) var itemFour: ItemType?
    private(set) var itemFive: ItemType?
    private(set) var itemSix: ItemType?
    private(set) var itemSeven: ItemType?
    
    private(set) var count: Int = 0
    
    mutating func removeAllUnsafe() {
        count = 0
    }
    
    mutating func append(item: ItemType) {
        setItem(item, atIndex: count)
        count += 1
    }
    
    subscript(index: Int) -> ItemType {
        get {
            return itemAtIndex(index)
        }
        set(newValue) {
            setItem(newValue, atIndex: index)
        }
    }
    
    private mutating func setItem(item: ItemType, atIndex index: Int) {
        if index == 0 {
            itemOne = item
        } else if index == 1 {
            itemTwo = item
        } else if index == 2 {
            itemThree = item
        } else if index == 3 {
            itemFour = item
        } else if index == 4 {
            itemFive = item
        } else if index == 5 {
            itemSix = item
        } else if index == 6 {
            itemSeven = item
        } else {
            fatalError("Index \(index) is out of array bounds")
        }
    }
    
    private func itemAtIndex(index: Int) -> ItemType {
        if index == 0 {
            return itemOne!
        } else if index == 1 {
            return itemTwo!
        } else if index == 2 {
            return itemThree!
        } else if index == 3 {
            return itemFour!
        } else if index == 4 {
            return itemFive!
        } else if index == 5 {
            return itemSix!
        } else if index == 6 {
            return itemSeven!
        } else {
            fatalError("Index \(index) is out of array bounds")
        }
    }
}