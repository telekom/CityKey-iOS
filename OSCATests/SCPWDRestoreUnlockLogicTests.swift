//
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

