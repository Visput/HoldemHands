//
//  QuickArray.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/26/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct QuickArray<ItemType: Equatable>: Equatable {
    
    private(set) var first: ItemType?
    private var second: ItemType?
    private var third: ItemType?
    private var fourth: ItemType?
    private var fifth: ItemType?
    private var sixth: ItemType?
    private var seventh: ItemType?
    private var eighth: ItemType?
    
    private(set) var count: Int = 0
    
    var last: ItemType? {
        return itemAtIndex(count - 1)
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
            return first
        } else if index == 1 {
            return second
        } else if index == 2 {
            return third
        } else if index == 3 {
            return fourth
        } else if index == 4 {
            return fifth
        } else if index == 5 {
            return sixth
        } else if index == 6 {
            return seventh
        } else {
            return eighth
        }
    }
    
    private mutating func setItem(item: ItemType, atIndex index: Int) {
        if index == 0 {
            first = item
        } else if index == 1 {
            second = item
        } else if index == 2 {
            third = item
        } else if index == 3 {
            fourth = item
        } else if index == 4 {
            fifth = item
        } else if index == 5 {
            sixth = item
        } else if index == 6 {
            seventh = item
        } else {
            eighth = item
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
