//
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
