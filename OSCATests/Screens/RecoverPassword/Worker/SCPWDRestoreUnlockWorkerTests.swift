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
//  SCPWDRestoreUnlockWorkerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCPWDRestoreUnlockWorkerTests: XCTestCase {
    private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCPWDRestoreUnlockWorker {
        let request: SCRequestMock = SCRequestMock(successResponse: successData, errorResponse: error)
        return SCPWDRestoreUnlockWorker(requestFactory: request)
    }

    func testRecoverPasswordSuccess() {
        let successResponseData = """
 {
     "content": {
         "isSuccessful": true
     }
 }
 """
        let sut = prepareSut(with: successResponseData.data(using: .utf8))
        let expections = expectation(description: "recover password success")
        sut.recoverPassword("test@gmail.com", pwd: "test@123", completion: { successful, error in
            XCTAssertTrue(successful)
            expections.fulfill()
        })
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testRecoverPasswordFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "recover password failure")
        sut.recoverPassword("test@gmail.com", pwd: "test@123") { successful, error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error, sut.mapRequestError(mockedError))
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

}
