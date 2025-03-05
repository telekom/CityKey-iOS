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
//  SCRegistrationWorkerTests.swift
//  SmartCityTests
//
//  Created by Alexander Lichius on 28.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCRegistrationWorkerTests: XCTestCase {
    
    private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCBasicPOIGuideWorker {
        let request: SCRequestMock = SCRequestMock(successResponse: successData, errorResponse: error)
        return SCBasicPOIGuideWorker(requestFactory: request)
    }
    
    
    func testRegistrationSuccessParsing() {
        let registrationJson: String = """
       {
           "content": {
               "isSuccessful": true,
               "postalCode": "Darmstadt,Hesse is not supported!"
           }
       }
    """
        let worker = SCRegistrationWorker(requestFactory: MockRequest(registrationJson: registrationJson))
        let parsingCompletedExpectation = expectation(description: "parsing completed")
        let registrationModel = SCModelRegistration(eMail: "", pwd: "", language: "", birthdate: "", postalCode: "", privacyAccepted: false)
        worker.register(registration: registrationModel, completion: { (success, codeInfo, error) in
            XCTAssert(true)
            parsingCompletedExpectation.fulfill()
        })
        wait(for: [parsingCompletedExpectation], timeout: 1)
    }
    
    func testRegistrationErrorParsing() {
        let registrationJson: String = """
       {
      "content": {},
      "errors": [{
        "errorCode": "email.validation.error",
        "userMsg": "string"
      }]
    }
    """
        let worker = SCRegistrationWorker(requestFactory: MockRequest(registrationJson: registrationJson))
        let parsingCompletedExpectation = expectation(description: "parsing completed")
        let registrationModel = SCModelRegistration(eMail: "", pwd: "", language: "", birthdate: "", postalCode: "", privacyAccepted: false)
        worker.register(registration: registrationModel, completion: { (success, codeInfo, error) in
            XCTAssert(true)
            parsingCompletedExpectation.fulfill()
        })
        wait(for: [parsingCompletedExpectation], timeout: 1)
    }

}

private class MockRequest: SCRequestCreating, SCDataFetching {
    
    var registrationJson: String
    
    init(registrationJson: String) {
        self.registrationJson = registrationJson
    }
    
    private let errorcodeString = SCHandledRegistrationError.emailValidationError.rawValue
    
    func createRequest() -> SCDataFetching {
        return MockRequest(registrationJson: registrationJson)
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        let mockData = registrationJson.data(using: .utf8)!
        let baseModel = try? JSONDecoder().decode(SCHttpModelBaseResponse.self, from: mockData)
        if let errorInfo = baseModel?.errors?.first {
            let requestErrorDetails = SCRequestErrorDetails(errorCode: errorInfo.errorCode, userMsg: errorInfo.userMsg, errorClientTrace: "no trace")
            completion(.failure(SCRequestError.requestFailed(406, requestErrorDetails)))
        } else {
            completion(.success(mockData))
        }
        
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }

}
