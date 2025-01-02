//
//  SCEventWorkerTest.swift
//  OSCATests
//
//  Created by Bhaskar N S on 09/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCEventWorkerTest: XCTestCase {

    private func prepareSut(with successData: Data? = nil, error: SCRequestError? = nil) -> SCEventWorker {
        let request: SCRequestMock = SCRequestMock(successResponse: successData, errorResponse: error)
        return SCEventWorker(requestFactory: request)
    }
    
    func testFetchEventListSuccess() {
        let sut = prepareSut(with: JsonReader().readJsonFrom(fileName: "Events",
                                                             withExtension: "json"), error: nil)
        let expections = expectation(description: "EventListSuccess")
        sut.fetchEventList(cityID: 13, eventId: "1234", page: 1, pageSize: 25,
                           startDate: Date(), endDate: Date(),
                           categories: nil) { error, response in
            XCTAssertNotNil(response?.eventList)
            XCTAssertNil(error)
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchEventListWithEmpty() {
        let sut = prepareSut(with: Data(), error: nil)
        let expections = expectation(description: "EventListWithEmpty")
        sut.fetchEventList(cityID: 13, eventId: "1234", page: 1, pageSize: 25,
                           startDate: Date(), endDate: Date(),
                           categories: nil) { error, response in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchEventListWithError() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "EventListWithError")
        sut.fetchEventList(cityID: 13, eventId: "1234", page: 1, pageSize: 25,
                           startDate: Date(), endDate: Date(),
                           categories: nil) { error, response in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            XCTAssertEqual(error, sut.mapRequestError(mockedError))
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchCategoryListSuccess() {
        let successResponseData = JsonReader().readJsonFrom(fileName: "EventCategoryList",
                                                            withExtension: "json")
        let sut = prepareSut(with: successResponseData, error: nil)
        let expections = expectation(description: "FetchCategoryListSuccess")
        sut.fetchCategoryList(cityID: 13) { error, list in
            guard error == nil else {
                XCTFail("Test Failed")
                return nil
            }
            let model = JsonReader().parseJsonData(of: SCHttpModelResponse<[SCHttpModelCategories]>.self,
                                                   data: successResponseData)
            XCTAssertEqual(SCHttpEventCategoriesResult.toCategoriesList(model!.content),
                           list)
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchCategoryListFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "FetchCategoryListFailure")
        sut.fetchCategoryList(cityID: 13) { error, list in
            guard error != nil else {
                XCTFail("Test Failed")
                return nil
            }
            XCTAssertNotNil(error)
            XCTAssertNil(list)
            XCTAssertEqual(error, sut.mapRequestError(mockedError))
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testSaveEventAsFavoriteSuccess() {
        let eventFavSuccess = """
        {
        "content": 1
        }
        """
        let sut = prepareSut(with: eventFavSuccess.data(using: .utf8), error: nil)
        let expections = expectation(description: "SaveEventAsFavoriteSuccess")
        sut.saveEventAsFavorite(cityID: 13, eventId: 123456, markAsFavorite: true, completion: { error in
            guard error == nil else {
                XCTFail("Test Fail")
                return nil
            }
            expections.fulfill()
            return nil
        })
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testSaveEventAsFavoriteFailure() {
        let mockError = SCRequestError.unexpected(SCRequestErrorDetails(errorCode: "0",
                                                                    userMsg: "",
                                                                    errorClientTrace: "fetch failed with no error code"))
        let sut = prepareSut(with: nil, error: mockError)
        let expections = expectation(description: "SaveEventAsFavoriteFailure")
        sut.saveEventAsFavorite(cityID: 13, eventId: 123456, markAsFavorite: true, completion: { error in
            guard error != nil else {
                XCTFail("Test Fail")
                return nil
            }
            XCTAssertEqual(sut.mapRequestError(mockError), error)
            expections.fulfill()
            return nil
        })
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchEventListCountSuccess() {
        let eventFavSuccess = """
        {
        "content": 50
        }
        """
        let sut = prepareSut(with: eventFavSuccess.data(using: .utf8), error: nil)
        let expections = expectation(description: "FetchEventListCountSuccess")
        sut.fetchEventListCount(cityID: 13, eventId: "1234", startDate: Date(), endDate: Date(), categories: nil) { error, count in
            guard error == nil else {
                XCTFail("Test Fail")
                return nil
            }
            XCTAssertEqual(count, 50)
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchEventListCountFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "FetchEventListCountFailure")
        sut.fetchEventListCount(cityID: 13, eventId: "1234", startDate: Date(), endDate: Date(), categories: nil) { error, count in
            guard error != nil else {
                XCTFail("Test Fail")
                return nil
            }
            XCTAssertEqual(sut.mapRequestError(mockedError), error)
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchEventListForDashboardSuccess() {
        let sut = prepareSut(with: JsonReader().readJsonFrom(fileName: "Events", withExtension: "json"), error: nil)
        let expections = expectation(description: "FetchEventListForDashboardSuccess")
        sut.fetchEventListForDashboard(cityID: 13, eventId: "1234") { error, list in
            guard error == nil else {
                XCTFail("Fail")
                return nil
            }
            XCTAssertNotNil(list?.eventList)
            XCTAssertNil(error)
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchEventListForDashboardFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "EventListForDashboardFailure")
        sut.fetchEventListForDashboard(cityID: 13, eventId: "1234") { error, list in
            guard error != nil else {
                XCTFail("Fail")
                return nil
            }
            XCTAssertNotNil(error)
            XCTAssertNil(list)
            XCTAssertEqual(error, sut.mapRequestError(mockedError))
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchEventListforOverviewSuccess() {
        let successResponseData = JsonReader().readJsonFrom(fileName: "EventsFilteredList",
                                                            withExtension: "json")
        let sut = prepareSut(with: successResponseData, error: nil)
        let expections = expectation(description: "FetchEventListforOverviewSuccess")
        sut.fetchEventListforOverview(cityID: 15, eventId: "1234", page: 1, pageSize: 25, startDate: Date(), endDate: Date(),
                                      categories: [SCModelCategory(categoryName: "", id: 70)]) { error, list in
            guard error == nil else {
                XCTFail("Test Failed")
                return nil
            }
            let model = JsonReader().parseJsonData(of: SCHttpModelResponse<[SCHttpEventModel]>.self,
                                                   data: successResponseData)
            XCTAssertEqual(SCHttpEventModelResult.toEventModel(model!.content), list)
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchEventListforOverviewFailure() {
        let mockedError = SCRequestError.noInternet
        let sut = prepareSut(with: nil, error: mockedError)
        let expections = expectation(description: "FetchEventListforOverviewFailure")
        sut.fetchEventListforOverview(cityID: 15, eventId: "1234", page: 1, pageSize: 25, startDate: Date(), endDate: Date(), categories: [SCModelCategory(categoryName: "", id: 70)]) { error, list in
            guard error != nil else {
                XCTFail("Test Failed")
                return nil
            }
            XCTAssertNotNil(error)
            XCTAssertNil(list)
            XCTAssertEqual(error, sut.mapRequestError(mockedError))
            expections.fulfill()
            return nil
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testResetDashboardEventListDataState() {
        let sut = prepareSut(with: nil, error: nil)
        sut.resetDashboardEventListDataState()
        XCTAssertFalse(sut.dashboardEventListDataState.dataInitialized)
        XCTAssertEqual(sut.dashboardEventListDataState.dataLoadingState, .needsToBefetched)
    }
}
