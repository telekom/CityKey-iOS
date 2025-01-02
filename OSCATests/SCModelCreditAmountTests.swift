//
//  SCModelCreditAmountTests.swift
//  SmartCityTests
//
//  Created by Alexander Lichius on 22.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest

class SCModelCreditAmountTests: XCTestCase {

    func testCreditAmountWithHttpModel() {
        let httpModel = SCHttpModelCreditAmount(maxAllowedChargeAmountInHundreds: 100, maxBalanceInHundreds: 1000, privateBalanceInHundreds: 900)
        let creditAmountModel = httpModel.toModel()
        XCTAssertTrue(creditAmountModel.maxBalance == 10)
        XCTAssertTrue(creditAmountModel.maxAllowedChargeAmount == 1)
        XCTAssertTrue(creditAmountModel.privateBalance == 9)
    }
    
    

}
