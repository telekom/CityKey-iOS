/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*///
//  SCPWDRestoreUnlockLogicTests.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 24.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCPWDRestoreUnlockLogicTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
/*
    func testValidateEmail() {
        let logic = SCPWDRestoreUnlockLogic(service: SCPWDRestoreUnlockService(requestFactory: MockPWDRestoreUnlockLogicRequest()))
        
        let result1 = logic.validateEmail("")
        XCTAssertFalse(result1.isValid)
        XCTAssertNotNil(result1.message)
        
        let result2 = logic.validateEmail("test")
        XCTAssertFalse(result2.isValid)
        XCTAssertNotNil(result2.message)
        XCTAssertNotEqual(result1.message, result2.message)
        
        let result3 = logic.validateEmail("test@test.de")
        XCTAssertTrue(result3.isValid)
        XCTAssertNil(result3.message)
    }*/

}

fileprivate class MockPWDRestoreUnlockLogicRequest: SCDataFetching, SCRequestCreating {
    let profileJson = """
        {"status":"OK",
        "content":"",
        "message":"just mock data"}
        """
    
    func fetchData(from url: URL,
                   method: String,
                   body: Data?,
                   needsAuth: Bool,
                   completion:@escaping ((SCRequestResult) -> ())) {
        let mockData = profileJson.data(using: .utf8)!
        completion(.success(mockData))
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func createRequest() -> SCDataFetching {
        return MockPWDRestoreUnlockLogicRequest()
    }
    
    func cancel(){
    }

}

