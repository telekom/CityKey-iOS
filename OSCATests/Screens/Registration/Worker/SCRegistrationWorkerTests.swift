//
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
