//
//  SCCitizenSingleSurveyWorkerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 16/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCitizenSingleSurveyWorkerTests: XCTestCase {
    
    private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCCitizenSingleSurveyWorker {
        let request: SCRequestMock = SCRequestMock(successResponse: successData, errorResponse: error)
        return SCCitizenSingleSurveyWorker(requestFactory: request)
    }
    
    func testGetSurveySuccess() {
        let successResponseData = JsonReader().readJsonFrom(fileName: "SurveyDetails",
                                                            withExtension: "json")
        let sut = prepareSut(with: successResponseData, error: nil)
        let expections = expectation(description: "survey Success")
        sut.getSurvey(for: 29, cityId: 16) { citizenSurvey, error in
            guard error == nil else {
                XCTFail("Test Failed")
                return
            }
            XCTAssertNotNil(citizenSurvey)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testGetSurveyFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "survey Failure")
        sut.getSurvey(for: 29, cityId: 16) { citizenSurvey, error in
            guard error != nil else {
                XCTFail("Test Failed")
                return
            }
            XCTAssertNotNil(error)
            XCTAssertNil(citizenSurvey)
            XCTAssertEqual(error, sut.mapRequestError(mockedError))
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}
