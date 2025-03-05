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
//  SCRegistrationConfirmEMailWorkerTests.swift
//  SmartCityTests
//
//  Created by Michael on 29.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCRegistrationConfirmEMailWorkerTests: XCTestCase {
    
    private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCRegistrationConfirmEMailWorker {
        let request: SCRequestMock = SCRequestMock(successResponse: successData, errorResponse: error)
        return SCRegistrationConfirmEMailWorker(requestFactory: request)
    }
    
    
    func testResendEmailParsingSuccessResult() {
        let worker = SCRegistrationConfirmEMailWorker(requestFactory: MockRequest())
        
        let parsingCompletedExpectation = expectation(description: "parsing completed")
        
        worker.resendEmail("correct@email.com", actionName: "PUT_ResendVerificationPIN") { (successful, error) in
            
            XCTAssertNil(error)
            XCTAssertTrue(successful)

            parsingCompletedExpectation.fulfill()
        }

        wait(for: [parsingCompletedExpectation], timeout: 1)

     }
    
    func testResendEmailParsingFailureResult() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expectation = expectation(description: "resend pin failure")
        
        sut.resendEmail("correct@email.com", actionName: "PUT_ResendVerificationPIN") { (successful, error) in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
     }
    
    func testValidatePinSuccess() {
        let successResponseData = """
 {
     "content": {
         "isSuccessful": true
     }
 }
 """
        let sut = prepareSut(with: successResponseData.data(using: .utf8))
        let expections = expectation(description: "recover password success")
        sut.validatePin("correct@email.com", actionName: "POST_ValidatePIN", pin: "11111") { successful, error in
            XCTAssertTrue(successful)
            expections.fulfill()
        }
        wait(for: [expections], timeout: 1)
    }
    
    func testValidatePinFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expectation = expectation(description: "validate pin failure")
        
        sut.validatePin("correct@email.com", actionName: "POST_ValidatePIN", pin: "11111") { successful, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

}


private class MockRequest: SCRequestCreating, SCDataFetching {
    
    
    func createRequest() -> SCDataFetching {
        return MockRequest()
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        
        let mockData = userJson.data(using: .utf8)!

        completion(SCRequestResult.success(mockData))
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }

    private let userJson = """
{
    "content": {
        "isSuccessful": true
    }
}
"""
}
