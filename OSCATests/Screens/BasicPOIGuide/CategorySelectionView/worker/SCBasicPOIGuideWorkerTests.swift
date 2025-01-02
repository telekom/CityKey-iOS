//
//  SCBasicPOIGuideWorkerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 31/05/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCBasicPOIGuideWorkerTests: XCTestCase {
	private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCBasicPOIGuideWorker {
		let request: SCRequestMock = SCRequestMock(successResponse: successData, errorResponse: error)
		return SCBasicPOIGuideWorker(requestFactory: request)
	}
	
	func testGetCityPOIWithSuccess() {
		let successResponseData = JsonReader().readJsonFrom(fileName: "CityPOI",
															withExtension: "json")
		let sut = prepareSut(with: successResponseData, error: nil)
		let expections = expectation(description: "city POI")
		sut.getCityPOI(cityId: "12", latitude: 0.0, longitude: 0.0, categoryId: "6") { pois, error in
			guard error == nil else {
				XCTFail("Test Failed")
				return
			}
			XCTAssertNotNil(pois)
			expections.fulfill()
		}
		waitForExpectations(timeout: 3.0, handler: nil)
	}
	
	func testGetCityPOIWithFailure() {
		let mockError = SCRequestError.unexpected(SCRequestErrorDetails(errorCode: "0",
																			userMsg: "",
				   errorClientTrace: "fetch failed with no error code"))
		let sut = prepareSut(with: nil, error: mockError)
		let expections = expectation(description: "city POI")
		sut.getCityPOI(cityId: "12", latitude: 0.0, longitude: 0.0, categoryId: "6") { pois, error in
			guard error != nil else {
				XCTFail("Test Failed")
				return
			}
			XCTAssertEqual(sut.mapRequestError(mockError), error)
			expections.fulfill()
		}
		waitForExpectations(timeout: 3.0, handler: nil)
	}
	
	func testGetCityPOICategoriesSuccess() {
		let successResponseData = JsonReader().readJsonFrom(fileName: "CityPOICategories",
															withExtension: "json")
		let sut = prepareSut(with: successResponseData, error: nil)
		let expections = expectation(description: "cityPOI Categories")
		sut.getCityPOICategories(cityId: "12") { categories, error in
			guard error == nil else {
				XCTFail("Test Failed")
				return
			}
			XCTAssertNotNil(categories)
			expections.fulfill()
		}
		waitForExpectations(timeout: 3.0, handler: nil)
	}
	
	func testGetCityPOICategories() {
		let mockError = SCRequestError.unexpected(SCRequestErrorDetails(errorCode: "0",
																		userMsg: "",
																		errorClientTrace: "fetch failed with no error code"))
		let sut = prepareSut(with: nil, error: mockError)
		let expections = expectation(description: "cityPOI categories failied")
		sut.getCityPOICategories(cityId: "12") { categories, error in
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
