//
//  DoubleTests.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import XCTest
@testable import HoldemHands

class DoubleTests: XCTestCase {

    func testCompareWithPrecision1() {
        let value1 = 1.11
        let value2 = 1.12
        XCTAssertTrue(value1.compare(value2, precision: 0.01) == .OrderedAscending)
    }
    
    func testCompareWithPrecision2() {
        let value1 = 1.116
        let value2 = 1.12
        XCTAssertTrue(value1.compare(value2, precision: 0.01) == .OrderedSame)
    }
    
    func testCompareWithPrecision3() {
        let value1 = 1.131
        let value2 = 1.139
        XCTAssertTrue(value1.compare(value2, precision: 0.01) == .OrderedAscending)
    }
    
    func testCompareWithPrecision4() {
        let value1 = 1.135
        let value2 = 1.134
        XCTAssertTrue(value1.compare(value2, precision: 0.01) == .OrderedDescending)
    }
    
    func testCompareWithPrecision5() {
        let value1 = 1.1
        let value2 = 1.1
        XCTAssertTrue(value1.compare(value2, precision: 0.01) == .OrderedSame)
    }
    
    func testCompareWithPrecision6() {
        let value1 = 1.11111111
        let value2 = 1.11111112
        XCTAssertTrue(value1.compare(value2, precision: 0.01) == .OrderedSame)
    }
    
    func testCompareWithPrecision7() {
        let value1 = 1.99999999
        let value2 = 2.0
        XCTAssertTrue(value1.compare(value2, precision: 0.01) == .OrderedSame)
    }
    
    func testCompareWithPrecision8() {
        let value1 = 1.11
        let value2 = 1.12
        XCTAssertTrue(value1.compare(value2, precision: 0.1) == .OrderedSame)
    }
    
    func testCompareWithPrecision9() {
        let value1 = 1.11
        let value2 = 1.12
        XCTAssertTrue(value1.compare(value2, precision: 0.02) == .OrderedSame)
    }
}
