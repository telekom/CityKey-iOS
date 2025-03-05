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
//  SCCitizenSurveyDataPrivacyPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 19/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCitizenSurveyDetailViewDelegateMock: SCCitizenSurveyDetailViewDelegate {
    private(set) var isAcceptPrivacyCalled: Bool = false
    
    func acceptedDataPrivacy() {
        isAcceptPrivacyCalled = true
    }
}

final class SCDataCacheMock: SCDataCaching {
    
    private var wasteCalendarItems : [SCModelWasteCalendarItem]?
    private var wasteCalendarItemsCityID: Int?
    private var wasteCalendarAddress: SCModelWasteCalendarAddress?
    private var currentEventsOverviewData: SCEventsOverviewData?
    private var currentEventsOverviewDataCityID: Int?
    private var barcode: SCModelBarcodeID?
    private var barcodeUserID: String?
    private(set) var citizenSurveyDict = [Int: Bool]()
    private(set) var citizenSurveyCityID: String?
    
    func wasteCalendarItems(for cityID: Int) -> [OSCA.SCModelWasteCalendarItem]? {
        return nil
    }
    
    func storeWasteCalendarItems(_: [OSCA.SCModelWasteCalendarItem], for cityID: Int) {
        
    }
    
    func getWasteCalendarAddress(cityID: Int) -> OSCA.SCModelWasteCalendarAddress? {
        return nil
    }
    
    func storeWasteCalendar(address: OSCA.SCModelWasteCalendarAddress, for cityID: Int) {
        
    }
    
    func eventsOverviewData(for cityID: Int) -> OSCA.SCEventsOverviewData? {
        return nil
    }
    
    func storeEventOverviewData(eventOverviewData: OSCA.SCEventsOverviewData, for cityID: Int) {
        
    }
    
    func storeLibraryID(libraryId: OSCA.SCModelBarcodeID, for userID: String) {
        
    }
    
    func getLibraryID(for userID: String) -> OSCA.SCModelBarcodeID? {
        return nil
    }
    
    func isDataPrivacyAccepted(for surveyId: Int, cityID: String) -> Bool? {
        if cityID != citizenSurveyCityID {
            citizenSurveyDict.removeAll()
        }
        return citizenSurveyDict[surveyId]
    }
    
    func setDataPrivacyAccepted(for surveyId: Int, cityID: String) {
        citizenSurveyDict[surveyId] = true
        citizenSurveyCityID = cityID
    }
    
    func clearCache() {
        self.currentEventsOverviewData = nil
        self.currentEventsOverviewDataCityID = nil
        self.barcode = nil
        self.barcodeUserID = nil
        citizenSurveyDict.removeAll()
    }
}


final class SCCitizenSurveyDataPrivacyPresenterTests: XCTestCase {
    
    private func prepareSut(cityContentSharedWorker: SCCityContentSharedWorking? = nil, dataCache: SCDataCaching? = nil,
                            delegate: SCCitizenSurveyDetailViewDelegate? = nil) -> SCCitizenSurveyDataPrivacyPresenter {
        
        let dpn = DataPrivacyNotice(content: [Content(dpnText: "dpnText")])
        let citizenSurveyOverview = SCModelCitizenSurveyOverview(isDpAccepted: true, id: 12, name: "", description: "",
                                                                 startDate: Date(), endDate: Date(), isPopular: true,
                                                                 status: .inProgress, dataProtectionText: "", isClosed: false,
                                                                 totalQuestions: 3, attemptedQuestions: 1, daysLeft: 3)
        return SCCitizenSurveyDataPrivacyPresenter(survey: citizenSurveyOverview,
                                                   dataCache: dataCache ?? SCDataCache(),
                                                   delegate: delegate ?? SCCitizenSurveyDetailViewDelegateMock(),
                                                   cityContentSharedWorker: cityContentSharedWorker ?? SCCityContentSharedWorkerMock(),
                                                   dataPrivacyNotice: dpn)
    }
    
    func testGetDataPrivacyContent() {
        let sut = prepareSut()
        let content = sut.getDataPrivacyContent()
        print(content ?? "")
        XCTAssertNotNil(content)
    }
    
    func testSetDataPrivacyAccepted() {
        let mockCityId = "13"
        let surveyId = 12
        let dataCache = SCDataCacheMock()
        let sut = prepareSut(dataCache: dataCache)
        sut.setDataPrivacyAccepted()
        XCTAssertTrue(dataCache.citizenSurveyDict[surveyId] ?? false)
        XCTAssertEqual(dataCache.citizenSurveyCityID, mockCityId)
    }
    
    func testInformDataPrivacyAccepted() {
        let mockDelegate: SCCitizenSurveyDetailViewDelegate? = SCCitizenSurveyDetailViewDelegateMock()
        let sut = prepareSut(delegate: mockDelegate)
        sut.informDataPrivacyAccepted()
        guard let delegate = mockDelegate as? SCCitizenSurveyDetailViewDelegateMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(delegate.isAcceptPrivacyCalled)
    }

}
