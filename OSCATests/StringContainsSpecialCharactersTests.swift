//
//  StringContainsSpecialCharactersTests.swift
//  SmartCityTests
//
//  Created by Alexander Lichius on 05.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class StringContainsSpecialCharactersTests: XCTestCase {

    func testContainsNoSpecialCharacter() {
        let testString = "abc"
        let containsSpecialCharacters = testString.containsSpecialCharacter()
        XCTAssertFalse(containsSpecialCharacters)
    }
    
    func testUmlauteAreNoSpecialCharacters() {
        let testString = "üÜöÖäÄß"
        let containsSpecialCharacters = testString.containsSpecialCharacter()
        XCTAssertFalse(containsSpecialCharacters)
    }
    
    func testSpaceIsNoValidCharacter() {
        let testString = " "
        let containsSpace = testString.containsSpace()
        XCTAssertTrue(containsSpace)
    }
    
    func testPasswordIsNotValid() {
        let testString = "12345678! "
        XCTAssertFalse(!testString.containsSpace() && testString.containsSpecialCharacter())
    }
    
    func testPasswordWithSpaceIsNotValid() {
        let testString = "1234 5678!"
        XCTAssertFalse(!testString.containsSpace() && testString.containsSpecialCharacter())
    }
    
    func testComaIsSpecialCharacter() {
        XCTAssert(",".containsSpecialCharacter())
    }
    
    func testQuestionMarkIsSpecialCharacter() {
        XCTAssert("?".containsSpecialCharacter())
    }
    
    func testExclamationMarkIsSpecialCharacter() {
        XCTAssert("!".containsSpecialCharacter())
    }
    
    func testEuroIsSpecialCharacter() {
        XCTAssert("€".containsSpecialCharacter())
    }
    
    func testDollarIsSpecialCharacter() {
        XCTAssert("$".containsSpecialCharacter())
    }
    
    func testBracketIsSpecialCharacter() {
        XCTAssert("(".containsSpecialCharacter())
    }
    
    func testMoreThanOneSpecialCharacter() {
        XCTAssert("?!§$%&/()=?".containsSpecialCharacter())
    }
    
}
