//
//  SCEditPasswordWorkerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 13/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCEditPasswordWorkerTests: XCTestCase {

    private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCEditPasswordWorker {
        let request: SCRequestMock = SCRequestMock(successResponse: successData, errorResponse: error)
        return SCEditPasswordWorker(requestFactory: request)
    }
    
    func testChangePasswordFailure() {
        let mockError = SCRequestError.unexpected(SCRequestErrorDetails(errorCode: "oldPwd.incorrect",
                                                                    userMsg: "The old password is incorrect.",
                                                                    errorClientTrace: "fetch failed with no error code"))
        let sut = prepareSut(with: nil, error: mockError)
        let expections = expectation(description: "ChangePasswordFailure")
        sut.changePassword(currentPassword: "cityKey@123", newPassword: "CityKey@123") { [weak sut] error in
            guard sut != nil else {
                XCTFail("Test Failed")
                return
            }
            XCTAssertEqual(sut?.mapRequestError(mockError), error)
            XCTAssertNotNil(error)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testChangePasswordSuccess() {
        let successResponse = """
        {
        "content": {
        "isSuccessful": true
        }
        }
        """
        let sut = prepareSut(with: successResponse.data(using: .utf8), error: nil)
        let expections = expectation(description: "ChangePasswordFailure")
        sut.changePassword(currentPassword: "cityKey@123", newPassword: "CityKey@123") { [weak sut] error in
            guard sut != nil,
                  error == nil else {
                XCTFail("Test Failed")
                return
            }
            XCTAssertNil(error)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

}
