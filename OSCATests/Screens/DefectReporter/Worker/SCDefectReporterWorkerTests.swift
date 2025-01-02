//
//  SCDefectReporterWorkerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterWorkerTests: XCTestCase {

    private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCDefectReporterWorker{
        return SCDefectReporterWorker(requestFactory: SCRequestMock(successResponse: successData,
                                                                    errorResponse: error))
    }
    
    func testGetDefectCategoriesSuccess() {
        let responseData = JsonReader().readJsonFrom(fileName: "CityDefectCategories",
                                                 withExtension: "json")
        let sut = prepareSut(with: responseData,
                             error: nil)
        let mockResponse = JsonReader().parseJsonData(of: SCHttpModelResponse<[SCHttpModelDefectCategory]>.self, data: responseData)
        let defectCategoryContent = mockResponse?.content.map {$0.toModel()}
        
        let expections = expectation(description: "CityDefectCategoriesSuccess")
        sut.getDefectCategories(cityId: "13") { [weak sut] defectCategoryList, error in
            guard sut != nil else {
                XCTFail("Test Failed")
                return
            }
            XCTAssertEqual(defectCategoryContent, defectCategoryList)
            XCTAssertNotNil(defectCategoryList)
            XCTAssertNil(error)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testGetDefectCategoriesFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "DefectCategoriesFailure")
        sut.getDefectCategories(cityId: "13") { list, error in
            guard error != nil else {
                XCTFail("Test Failed")
                return
            }
            XCTAssertNotNil(error)
            XCTAssertTrue(list.isEmpty)
            XCTAssertEqual(error, sut.mapRequestError(mockedError))
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testSubmitDefectFailure() {
        let mockedError = SCRequestError.requestFailed(500,
                                                       SCRequestErrorDetails(errorCode: "defect_outside_city",
                                                                             userMsg: "Sorry, unfortunately the specified location is not in our local jurisdiction. Please check the position.",
                                                                             errorClientTrace: "no trace"))
        let sut = prepareSut(with: nil, error: mockedError)
        let model = SCModelDefectRequest(lastName: "", firstName: "",
                                         serviceCode: "", lat: "50.6426", long: "7.2262",
                                         email: "", description: "", mediaUrl: "",
                                         wasteBinId: "", subServiceCode: "",
                                         location: "L83, 56745 Volkesfeld, Germany", streetName: "",
                                         houseNumber: "", postalCode: "56745",
                                         phoneNumber: "")
        let expections = expectation(description: "SubmitDefectFailure")
        sut.submitDefect(cityId: "13", defectRequest: model) { [weak sut] uniqueId, error in
            guard sut != nil else {
                XCTFail("Test failed")
                return
            }
            XCTAssertNil(uniqueId)
            XCTAssertEqual(error, sut?.mapRequestError(mockedError))
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testSubmitDefectSuccess() {
        let successResponse = """
        {
            "content": {
                "uniqueId": "85184"
            }
        }
        """
        let mockModel = JsonReader().parseJsonData(of: SCHttpModelResponse<SCDefectReporterWorker.SCHttpResponseDefectRequest>.self,
                                                   data: successResponse.data(using: .utf8)!)
        let sut = prepareSut(with: successResponse.data(using: .utf8), error: nil)
        let model = SCModelDefectRequest(lastName: "", firstName: "",
                                         serviceCode: "", lat: "50.6426", long: "7.2262",
                                         email: "", description: "", mediaUrl: "",
                                         wasteBinId: "", subServiceCode: "",
                                         location: "L83, 56745 Volkesfeld, Germany", streetName: "",
                                         houseNumber: "", postalCode: "56745",
                                         phoneNumber: "")
        let expections = expectation(description: "SubmitDefectSuccess")
        sut.submitDefect(cityId: "13", defectRequest: model) { [weak sut] uniqueId, error in
            guard sut != nil else {
                XCTFail("Test failed")
                return
            }
            XCTAssertEqual(mockModel!.content.uniqueId, uniqueId)
            XCTAssertNil(error)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testUploadDefectImageFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "UploadDefectImageFailure")
        sut.uploadDefectImage(cityId: "13", imageData: Data()) { [weak sut] mediaURL, error in
            guard sut != nil else {
                XCTFail("Test failed")
                return
            }
            XCTAssertNil(mediaURL)
            XCTAssertEqual(error, sut?.mapRequestError(mockedError))
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testUploadDefectImageSuccess() {
        let successResponse = """
             {
                 "content": {
                     "mediaURL": "https://defect-reporter.obs.otc.t-systems.com/qa/1658479051928_7041.jpeg"
                 }
             }
        """
        let mockModel = JsonReader().parseJsonData(of: SCHttpModelResponse<SCDefectReporterWorker.SCHttpResponseDefectImageRequest>.self,
                                                   data: successResponse.data(using: .utf8)!)
        let sut = prepareSut(with: successResponse.data(using: .utf8)!,
                             error: nil)
        let expections = expectation(description: "UploadDefectImageSuccess")
        sut.uploadDefectImage(cityId: "13", imageData: Data()) { [weak sut] mediaURL, error in
            guard sut != nil else {
                XCTFail("Test failed")
                return
            }
            XCTAssertNil(error)
            XCTAssertEqual(mockModel!.content.mediaURL, mediaURL)
            expections.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}
