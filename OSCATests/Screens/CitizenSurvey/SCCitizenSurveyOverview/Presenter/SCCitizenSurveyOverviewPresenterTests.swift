//
//  SCCitizenSurveyOverviewPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 20/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCitizenSurveyOverviewPresenterTests: XCTestCase {
    weak var display: SCCitizenSurveyOverviewDisplaying?
    private func prepareSut(surveyList: [SCModelCitizenSurveyOverview]? = nil,
                            citizenSurveyWorker: SCCitizenSurveyWorking? = nil) -> SCCitizenSurveyOverviewPresenter {
        return SCCitizenSurveyOverviewPresenter(surveyList: surveyList ?? getMockModelCitizenSurveyOverview(),
                                                cityContentSharedWorker: SCCityContentSharedWorkerMock(),
                                                surveyWorker: citizenSurveyWorker ?? SCCitizenSurveyWorker(requestFactory: SCRequestMock()),
                                                injector: MockSCInjector(),
                                                serviceData: getServiceData())
    }
    
    private func getMockModelCitizenSurveyOverview() -> [SCModelCitizenSurveyOverview] {
        [SCModelCitizenSurveyOverview(isDpAccepted: true, id: 12, name: "TestSurvey", description: "TestSurveyDescription",
                                         startDate: Date(), endDate: Date(), isPopular: true,
                                         status: .inProgress, dataProtectionText: "", isClosed: false,
                                         totalQuestions: 3, attemptedQuestions: 1, daysLeft: 3)]
    }
    
    private func getServiceData() -> SCBaseComponentItem {
        SCBaseComponentItem(itemID: "", itemTitle: "", itemImageURL: SCImageURL(urlString: "test/image", persistence: false), itemHtmlDetail: false, itemColor: .blue)
    }
    
    func testViewDidLoad() {
        let sut = prepareSut(surveyList: [])
        let display = SCCitizenSurveyOverviewDisplayer()
        sut.set(display: display)
        sut.viewDidLoad()
        XCTAssertTrue(display.isDisplayNoSurveyEmptyView)
    }
    
    func testGetSurveyList() {
        let surveyOverviewMock = getMockModelCitizenSurveyOverview()
        let sut = prepareSut()
        let display = SCCitizenSurveyOverviewDisplayer()
        sut.set(display: display)
        XCTAssertEqual(sut.getSurveyList(), surveyOverviewMock)
    }
    
    func TestdisplaySurveyDetails() {
        let surveyOverView = SCModelCitizenSurveyOverview(isDpAccepted: true, id: 12, name: "TestSurvey",
                                                          description: "TestSurveyDescription",
                                                          startDate: Date(), endDate: Date(), isPopular: true,
                                                          status: .inProgress, dataProtectionText: "", isClosed: false,
                                                          totalQuestions: 3, attemptedQuestions: 1, daysLeft: 3)
        let sut = prepareSut()
        let display = SCCitizenSurveyOverviewDisplayer()
        sut.set(display: display)
        sut.displaySurveyDetails(survey: surveyOverView)
        XCTAssertTrue(display.isPushCalled)
    }
    
    func testFetchSurveyListSuccess() {
        let surveyOverviewMock = getMockModelCitizenSurveyOverview()
        let successResponseData = JsonReader().readJsonFrom(fileName: "CitySurvey",
                                                            withExtension: "json")
        let surveyWorker = SCCitizenSurveyWorker(requestFactory: SCRequestMock(successResponse: successResponseData))
        let sut = prepareSut(citizenSurveyWorker: surveyWorker)
        let display = SCCitizenSurveyOverviewDisplayer()
        sut.set(display: display)
        sut.fetchSurveyList()
        let exp = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(display.isEndRefreshingCalled)
            XCTAssertTrue(display.isUpdateDataSourceCalled)
            XCTAssertNotNil(sut.getSurveyList())
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testFetchSurveyListWithError() {
        let mockError = SCRequestError.unexpected(SCRequestErrorDetails(errorCode: "0",
                                                                    userMsg: "",
                                                                    errorClientTrace: "fetch failed with no error code"))
        let surveyWorker = SCCitizenSurveyWorker(requestFactory: SCRequestMock(errorResponse: mockError))
        let sut = prepareSut(citizenSurveyWorker: surveyWorker)
        let display = SCCitizenSurveyOverviewDisplayer()
        sut.set(display: display)
        sut.fetchSurveyList()
        let exp = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(display.isEndRefreshingCalled)
        } else {
            XCTFail("Delay interrupted")
        }
    }

}

class SCCitizenSurveyOverviewDisplayer: SCCitizenSurveyOverviewDisplaying {
    var isDisplayNoSurveyEmptyView: Bool = false
    var isPushCalled: Bool = false
    var isUpdateDataSourceCalled: Bool = false
    var isEndRefreshingCalled: Bool = false
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func displayNoSurveyEmptyView() {
        isDisplayNoSurveyEmptyView = true
    }
    
    func updateDataSource() {
        isUpdateDataSourceCalled = true
    }
    
    func endRefreshing() {
        isEndRefreshingCalled = true
    }
    
    
}
