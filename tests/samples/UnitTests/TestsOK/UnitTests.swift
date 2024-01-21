//
//  UnitTests.swift
//  TestsOK
//
//  Copyright (c) 2024 BB9z, MIT License
//

import XCTest

final class UnitTests: XCTestCase {
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
