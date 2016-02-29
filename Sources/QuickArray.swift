//
//  QuickArray.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/26/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct QuickArray<ItemType: Equatable>: Equatable {
    
    private var itemOne: ItemType?
    private var itemTwo: ItemType?
    private var itemThree: ItemType?
    private var itemFour: ItemType?
    private var itemFive: ItemType?
    private var itemSix: ItemType?
    private var itemSeven: ItemType?
    private var itemEight: ItemType?
    
    private(set) var count: Int = 0
    
    var last: ItemType? {
        if count == 0 {
            return nil
        } else {
            return itemAtIndex(count - 1)
        }
    }
    
    var first: ItemType? {
        if count == 0 {
            return nil
        } else {
            return itemOne
        }
    }
    
    mutating func append(item: ItemType) {
        setItem(item, atIndex: count)
        count += 1
    }
    
    mutating func insert(item: ItemType, atIndex index: Int) {
        var newItem: ItemType? = item
        for subIndex in index ... count {
            let oldItem = itemAtIndex(subIndex)
            setItem(newItem!, atIndex: subIndex)
            newItem = oldItem
        }
        count += 1
    }
    
    mutating func removeAtIndex(index: Int) {
        if index <= count - 2 {
            for subIndex in index ... count - 2 {
                setItem(itemAtIndex(subIndex + 1)!, atIndex: subIndex)
            }
        }
        count -= 1
    }
    
    mutating func removeLast() {
        count -= 1
    }
    
    mutating func removeLast(numberOfItems: Int) {
        count -= numberOfItems
    }
    
    mutating func removeAll() {
        count = 0
    }
    
    subscript(index: Int) -> ItemType {
        get {
            return itemAtIndex(index)!
        }
        set(newValue) {
            setItem(newValue, atIndex: index)
        }
    }
    
    private func itemAtIndex(index: Int) -> ItemType? {
        if index == 0 {
            return itemOne
        } else if index == 1 {
            return itemTwo
        } else if index == 2 {
            return itemThree
        } else if index == 3 {
            return itemFour
        } else if index == 4 {
            return itemFive
        } else if index == 5 {
            return itemSix
        } else if index == 6 {
            return itemSeven
        } else if index == 7 {
            return itemEight
        } else {
            fatalError("Index \(index) is out of array bounds")
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
        } else if index == 7 {
            itemEight = item
        } else {
            fatalError("Index \(index) is out of array bounds")
        }
    }
}

func ==<ItemType: Equatable>(lhs: QuickArray<ItemType>, rhs: QuickArray<ItemType>) -> Bool {
    if lhs.count != rhs.count {
        return false
    } else {
        for index in 0 ..< lhs.count {
            if lhs[index] != rhs[index] {
                return false
            }
        }
    }
    return true
}
