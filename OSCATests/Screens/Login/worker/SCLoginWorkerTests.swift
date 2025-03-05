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
//  SCLoginWorkerTests.swift
//  SmartCityTests
//
//  Created by Michael on 29.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCLoginWorkerTests: XCTestCase {

    func testParsingSuccessResult() {
        
        SCAuth.shared.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: true))
        
        let worker = SCLoginWorker(requestFactory: MockRequest(), authProvider: SCAuth.shared)
        
        let loginSuccessfulExpectation = expectation(description: "login successful")
            
        worker.login(email: "correct@email.com", password: "password correct", remember: false) { (loginError) in
            XCTAssertEqual(SCAuth.shared.getRefreshToken(), "mocked_refresh_token")
            XCTAssertTrue(SCAuth.shared.isUserLoggedIn())
            
            loginSuccessfulExpectation.fulfill()
         }
        
        wait(for: [loginSuccessfulExpectation], timeout: 1)

    }
    
    func testParsingErrorResult() {
        
        SCAuth.shared.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: false))
        
        let worker = SCLoginWorker(requestFactory: MockRequest(), authProvider: SCAuth.shared)
        
        let loginSuccessfulExpectation = expectation(description: "login successful")
        
        worker.login(email: "wrong@email.com", password: "password correct", remember: false) { (error) in
            
            XCTAssertNotNil(error)
            
            switch error! {
            case .fetchFailed(let details):
                XCTAssertEqual(details.errorCode!, "user.active")
            default :
                XCTAssert(false)
            }

            XCTAssertNil(SCAuth.shared.getRefreshToken())

            loginSuccessfulExpectation.fulfill()
        }
        
        wait(for: [loginSuccessfulExpectation], timeout: 1)

    }
    
    func testLogout() {
        let auth: SCAuth & SCAuthTokenProviding = SCAuth.shared
        auth.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: true))
        
        let worker = SCLoginWorker(requestFactory: MockRequest(), authProvider: auth)
        let logoutSuccessfulExpectation = expectation(description: "logout successful")
        
        worker.login(email: "correct@email.com", password: "password correct", remember: false) { (loginError) in
            XCTAssertEqual(SCAuth.shared.getRefreshToken(), "mocked_refresh_token")
            XCTAssertTrue(SCAuth.shared.isUserLoggedIn())
        }
        worker.logout {
            XCTAssertNil(auth.getRefreshToken())
            logoutSuccessfulExpectation.fulfill()
        }
        
        wait(for: [logoutSuccessfulExpectation], timeout: 3)
    }
    
    func testClearLogoutResason() {
        let auth: SCAuth & SCAuthTokenProviding = SCAuth.shared
        auth.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: true))
        
        let worker = SCLoginWorker(requestFactory: MockRequest(), authProvider: SCAuth.shared)
        worker.clearLogoutResason()
        XCTAssertNil(auth.logoutReason())
    }
}

private class MockRequest: SCRequestCreating, SCDataFetching {
    
    
    func createRequest() -> SCDataFetching {
        return MockRequest()
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        
     }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }

}


fileprivate class MockAuthRequest: SCRequestCreating, SCDataFetching {
    
    public let success: Bool
    
    private let loginJson = """
        {
        "content": {
            "access_token": "mocked_access_token",
            "token_type": "bearer",
            "refresh_token": "mocked_refresh_token",
            "expires_in": 299,
            "scope": "email openid profile",
            "refresh_expires_in": 600
        }
        }
    """
    private let loginFailedJson = """
    {
        "error": {
            "errorCode": "user.active",
            "userMsg": "Invalid user credentials. Please try again."
        }
    }
    """
    
    let logoutJson = ""
    let refreshedJson = ""
    
    init(success: Bool) {
        self.success = success
    }
    
    func createRequest() -> SCDataFetching {
        return MockAuthRequest(success: self.success)
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        
        var jsonString: String = ""
        
        if url.absoluteString.contains("POST_Login") {
            jsonString = self.success ? loginJson : loginFailedJson
        } else {
            jsonString = "error"
        }
        
        let mockData = jsonString.data(using: .utf8)!
        
        self.success ? completion(.success(mockData)) : completion(.failure(SCRequestError.unauthorized(SCRequestErrorDetails(errorCode: "user.active", userMsg: "Invalid user credentials. Please try again.", errorClientTrace: ""))))
   }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }

}
