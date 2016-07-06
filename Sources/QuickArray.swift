//
//  QuickArray.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/26/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

struct QuickArray<ItemType: Equatable>: Equatable {
    
    private(set) var count: Int = 0
    
    var first: ItemType? {
        return buffer.first
    }
    
    var last: ItemType? {
        return buffer[count - 1]
    }
    
    var isEmpty: Bool {
        return count == 0
    }
    
    private var buffer: UnsafeMutableBufferPointer<ItemType>
    
    init(_ numberOfItems: Int) {
        buffer = UnsafeMutableBufferPointer<ItemType>(start: UnsafeMutablePointer<ItemType>.alloc(numberOfItems), count: numberOfItems)
    }
    
    func destroy() {
        buffer.baseAddress.destroy(buffer.count)
        buffer.baseAddress.dealloc(buffer.count)
    }
    
    @inline(__always) mutating func append(item: ItemType) {
        buffer[count] = item
        count += 1
    }
    
    @inline(__always) mutating func removeLast() {
        count -= 1
    }
    
    @inline(__always) mutating func removeAll() {
        count = 0
    }
    
    @inline(__always) mutating func insert(item: ItemType, atIndex index: Int) {
        var newItem: ItemType? = item
        for subIndex in index ... count {
            let oldItem = buffer[subIndex]
            buffer[subIndex] = newItem!
            newItem = oldItem
        }
        count += 1
    }
    
    @inline(__always) mutating func removeFirst() -> ItemType {
        return removeAtIndex(0)
    }
    
    @inline(__always) mutating func removeAtIndex(index: Int) -> ItemType {
        let item = buffer[index]
        if index <= count - 2 {
            for subIndex in index ... count - 2 {
                buffer[subIndex] = buffer[subIndex + 1]
            }
        }
        count -= 1
        
        return item
    }
    
    @inline(__always) func indexOf(item: ItemType) -> Int? {
        return buffer.indexOf(item)
    }
    
    @inline(__always) mutating func sortInPlace(@noescape isOrderedBefore: (ItemType, ItemType) -> Bool) {
        return buffer.sortInPlace(isOrderedBefore)
    }
    
    subscript(index: Int) -> ItemType {
        @inline(__always) get {
            return buffer[index]
        }
        @inline(__always) set(newValue) {
            buffer[index] = newValue
        }
    }
}

@inline(__always) func ==<ItemType: Equatable>(lhs: QuickArray<ItemType>, rhs: QuickArray<ItemType>) -> Bool {
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
