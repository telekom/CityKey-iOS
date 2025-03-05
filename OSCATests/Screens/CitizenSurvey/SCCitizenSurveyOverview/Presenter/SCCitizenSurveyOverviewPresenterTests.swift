/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*///
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
