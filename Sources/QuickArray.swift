//
//  QuickArray.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/26/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct QuickArray<ItemType> {
    
    private(set) var count: Int = 0
    
    var first: ItemType? {
        return buffer[0]
    }
    
    var last: ItemType? {
        return buffer[count - 1]
    }
    
    private var buffer: UnsafeMutableBufferPointer<ItemType>
    
    init(_ numberOfItems: Int) {
        buffer = UnsafeMutableBufferPointer<ItemType>(start: UnsafeMutablePointer<ItemType>.alloc(numberOfItems), count: numberOfItems)
    }
    
    func destroy() {
        buffer.baseAddress.destroy(buffer.count)
        buffer.baseAddress.dealloc(buffer.count)
    }
    
    mutating func append(item: ItemType) {
        buffer[count] = item
        count += 1
    }
    
    mutating func removeLast() {
        count -= 1
    }
    
    mutating func removeAll() {
        count = 0
    }
    
    mutating func insert(item: ItemType, atIndex index: Int) {
        var newItem: ItemType? = item
        for subIndex in index ... count {
            let oldItem = buffer[subIndex]
            buffer[subIndex] = newItem!
            newItem = oldItem
        }
        count += 1
    }
    
    mutating func removeAtIndex(index: Int) {
        if index <= count - 2 {
            for subIndex in index ... count - 2 {
                buffer[subIndex] = buffer[subIndex + 1]
            }
        }
        count -= 1
    }
    
    subscript(index: Int) -> ItemType {
        get {
            return buffer[index]
        }
        set(newValue) {
            buffer[index] = newValue
        }
    }
}
