//
//  BarCodeGeneratorTests.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 06.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class BarCodeGeneratorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEndcoding() {
        let barCode = BarCodeGenerator().encode("91021052")
        
        let expectedBarCode: BarCode  = [.black, .white, .black, .white, .black, .white, .white, .white, .black, .black, .black, .white, .black, .white, .black, .black, .black, .white, .black, .white, .white, .white, .black, .white, .black, .white, .white, .white, .black, .black, .black, .white, .black, .black, .black, .white, .black, .white, .white, .white, .black, .black, .black, .white, .black, .white, .black, .white, .white, .white, .black, .white, .white, .white, .black, .black, .black, .white, .black, .black, .black, .white, .black, .white, .white, .white, .black, .black, .black, .white, .black, .white, .black, .white, .white, .white, .black, .black, .black, .white, .black]
        
        XCTAssertEqual(barCode, expectedBarCode)
    }
    
    func testStringLengtIsOdd() {
        let barCode = BarCodeGenerator().encode("9102105")
        
        XCTAssertNil(barCode)
    }
    
    func testStringLengtIsTooLong() {
        let barCode = BarCodeGenerator().encode("12345678901")
        
        XCTAssertNil(barCode)
    }
    
    func testStringContainsNotANumber() {
        let barCode = BarCodeGenerator().encode("abcdefgh")
        
        XCTAssertNil(barCode)
    }
}
