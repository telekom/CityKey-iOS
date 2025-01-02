//
//  SCCitizenSurveyWorkerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 16/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCitizenSurveyWorkerTests: XCTestCase {
    
    private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCCitizenSurveyWorker {
        let request: SCRequestMock = SCRequestMock(successResponse: successData, errorResponse: error)
        return SCCitizenSurveyWorker(requestFactory: request)
    }
    
    func testGetSurveyOverviewSuccessWithSurveyAviable() {
        let successResponseData = JsonReader().readJsonFrom(fileName: "CitySurvey",
                                                            withExtension: "json")
        let sut = prepareSut(with: successResponseData, error: nil)
        let expections = expectation(description: "survey Success")
        sut.getSurveyOverview(ciyId: "12") { overview, error in
            guard error == nil else {
                XCTFail("Test Failed")
                return
            }
            XCTAssertNotNil(overview)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testGetSurveyOverviewSuccessWithNoActiveSurvey() {
        let successResponseData = """
        {
            "content": []
        }
        """
        let sut = prepareSut(with: successResponseData.data(using: .utf8), error: nil)
        let expections = expectation(description: "survey Success")
        sut.getSurveyOverview(ciyId: "12") { overview, error in
            guard error == nil else {
                XCTFail("Test Failed")
                return
            }
            XCTAssertTrue(overview.isEmpty)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testGetSurveyOverviewFailure() {
        let mockError = SCRequestError.unexpected(SCRequestErrorDetails(errorCode: "0",
                                                                    userMsg: "",
                                                                    errorClientTrace: "fetch failed with no error code"))
        let sut = prepareSut(with: nil, error: mockError)
        let expections = expectation(description: "survey Failure")
        sut.getSurveyOverview(ciyId: "13") { survey, error in
            guard error != nil else {
                XCTFail("Test Fail")
                return
            }
            XCTAssertEqual(sut.mapRequestError(mockError), error)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchDataPrivacyNoticeForPollsSuccess() {
        let successResponseData = """
        {
            "content": [{
                "dpn_text": "<p>Citykey does not collect or request any personal or personally identifiable information in the following survey. The City of Siegburg is responsible for the content of the survey. The results will be made available to the city of Siegburg by Citykey after completion of the survey and subsequently deleted in Citykey. The evaluation of the results is carried out by the city.</p><p><b>Important:</b> Please make sure not to enter any personal or person-related data in free text fields, as this content will also be transferred to the city in plain text.</p>"
            }]
        }
        """
        let sut = prepareSut(with: successResponseData.data(using: .utf8), error: nil)
        let expections = expectation(description: "DataPrivacyNotice")
        sut.fetchDataPrivacyNoticeForPolls(ciyId: "13") { notice, error in
            guard error == nil else {
                XCTFail("Test Failed")
                return
            }
            let model = JsonReader().parseJsonData(of: DataPrivacyNotice.self,
                                                   data: successResponseData.data(using: .utf8)!)

            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        
    }
    
    func testFetchDataPrivacyNoticeForPollsFailure() {
        let mockError = SCRequestError.unexpected(SCRequestErrorDetails(errorCode: "0",
                                                                    userMsg: "",
                                                                    errorClientTrace: "fetch failed with no error code"))
        let sut = prepareSut(with: nil, error: mockError)
        let expections = expectation(description: "DataPrivacyNoticeFailure")
        sut.fetchDataPrivacyNoticeForPolls(ciyId: "13") { dpn, error in
            guard error != nil else {
                XCTFail("Test Fail")
                return
            }
            XCTAssertEqual(sut.mapRequestError(mockError), error)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testSubmitSurveySuccess() {
        let successResponseData = """
        {
            "content": {
                "isSuccessful": true
            }
        }
        """
        let sut = prepareSut(with: successResponseData.data(using: .utf8), error: nil)
        let expections = expectation(description: "DataPrivacyNotice")
        let result = SCModelSurveyResult(totalQuestions: 3,
                                         attemptedQuestions: 3,
                                         responses: [SCModelSurveyQuestionResult(questionId: 92, topicId: 1, optionNo: 1, freeText: ""),
                                                     SCModelSurveyQuestionResult(questionId: 93, topicId: 1, optionNo: 2, freeText: ""),
                                                     SCModelSurveyQuestionResult(questionId: 91, topicId: 1, optionNo: 2, freeText: "")])
        sut.submitSurvey(ciyId: "13", surveyId: "16", surveyResult: result) { isSuccessful, error in
            guard error == nil else {
                XCTFail("Test Failed")
                return
            }
            XCTAssertTrue(isSuccessful)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
     
    func testSubmitSurveyFailure() {
        let mockError = SCRequestError.unexpected(SCRequestErrorDetails(errorCode: "0",
                                                                    userMsg: "",
                                                                    errorClientTrace: "fetch failed with no error code"))
        let sut = prepareSut(with: nil, error: mockError)
        let expections = expectation(description: "SubmitSurveyFailure")
        let result = SCModelSurveyResult(totalQuestions: 3,
                                         attemptedQuestions: 3,
                                         responses: [SCModelSurveyQuestionResult(questionId: 92, topicId: 1, optionNo: 1, freeText: ""),
                                                     SCModelSurveyQuestionResult(questionId: 93, topicId: 1, optionNo: 2, freeText: ""),
                                                     SCModelSurveyQuestionResult(questionId: 91, topicId: 1, optionNo: 2, freeText: "")])
        sut.submitSurvey(ciyId: "13", surveyId: "16", surveyResult: result) { isSuccessful, error in
            guard error != nil else {
                XCTFail("Test Fail")
                return
            }
            XCTAssertEqual(sut.mapRequestError(mockError), error)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}
