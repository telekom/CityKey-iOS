//
//  SCDeleteAccountConfirmationWorkerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 20/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDeleteAccountConfirmationWorkerTests: XCTestCase {

    private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCDeleteAccountConfirmationWorker {
        return SCDeleteAccountConfirmationWorker(requestFactory: SCRequestMock(successResponse: successData,
                                                                               errorResponse: error))
    }
    
    func testDeleteAccountSuccess() {
        let successResponse = """
        {
        "content": {
            "isSuccessful": true
        }
        }
        """
        let sut = prepareSut(with: successResponse.data(using: .utf8), error: nil)
        let expections = expectation(description: "DeleteAccountSuccess")
        sut.deleteAccount(_with: "test@123") { [weak sut] error in
            guard sut != nil else {
                XCTFail("Test failed")
                return
            }
            XCTAssertNil(error)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testDeleteAccountFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "DeleteAccountFailure")
        sut.deleteAccount(_with: "test@123") { [weak sut] error in
            guard sut != nil else {
                XCTFail("Test failed")
                return
            }
            XCTAssertNotNil(error)
            XCTAssertEqual(error, sut?.mapRequestError(mockedError))
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    

}
