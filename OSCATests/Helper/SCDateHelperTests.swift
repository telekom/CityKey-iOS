//
//  SCDateHelperTests.swift
//  SmartCityTests
//
//  Created by Alexander Lichius on 24.09.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDateHelperTests: XCTestCase {
    var date: Date?
    override func setUp() {
        date  = Date(timeIntervalSince1970: 0)
    }

    func testGetDayString() {
        let day = getDayName(_for: date!)
        XCTAssertEqual("Thu", day)
    }

    func testGetYearString() {
        let year = getYear(_for: date!)
        XCTAssertEqual("1970", year)
    }

    func testGetMonthString() {
        let month = getMonthName(_for: date!)
        XCTAssertEqual("Jan", month)
    }
    
    func DateFromString() {
        let dateString = "2001-08-30 09:00:00"
        let date = dateFromString(dateString: dateString)
        XCTAssertNotNil(date)
        XCTAssertTrue(date?.description(with: .current) == "Thursday, August 30, 2001 at 12:00:00 AM Central European Summer Time")
    }

}
