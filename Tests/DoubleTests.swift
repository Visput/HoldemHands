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

    func testCompareWithPrecision() {
        let value1 = 11.11
        let value2 = 11.12
        XCTAssertTrue(value1.compare(value2, precision: 0.01) == .OrderedSame)
    }
}
