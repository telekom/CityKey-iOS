//
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
