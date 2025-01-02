//
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
