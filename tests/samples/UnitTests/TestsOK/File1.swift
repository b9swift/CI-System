//
//  File1.swift
//  TestsOK
//
//  Copyright (c) 2024 BB9z, MIT License
//

import XCTest

final class Tests1: XCTestCase {
    func testOK() {
        XCTAssert(true)
    }

    func testSkip() throws {
        throw XCTSkip("Skip")
    }

    func testExpectedFailure() {
        XCTExpectFailure("Expected failure")
        XCTAssert(false)
    }
}
