//
//  SCCitizenSurveyDetailPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 19/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCitizenSurveyDetailPresenterTests: XCTestCase {
    weak var display: SCCitizenSurveyDetailDisplaying?
    
    private func prepareSut(singleSurveyWorker: SCCitizenSingleSurveyWorking? = nil,
                            dataCache: SCDataCaching? = nil,
                            surveyWorker: SCCitizenSurveyWorking? = nil) -> SCCitizenSurveyDetailPresenter {
        let survey = SCModelCitizenSurveyOverview(isDpAccepted: true, id: 12, name: "TestSurvey", description: "TestSurveyDescription",
                                                  startDate: Date(), endDate: Date(), isPopular: true,
                                                  status: .inProgress, dataProtectionText: "", isClosed: false,
                                                  totalQuestions: 3, attemptedQuestions: 1, daysLeft: 3)
        let serviceData = SCBaseComponentItem(itemID: "", itemTitle: "", itemImageURL: SCImageURL(urlString: "test/image", persistence: false), itemHtmlDetail: false, itemColor: .blue)
        return SCCitizenSurveyDetailPresenter(survey: survey,
                                              serviceData: serviceData,
                                              singleSurveyWorker: singleSurveyWorker ?? SCCitizenSingleSurveyWorker(requestFactory: SCRequestMock()),
                                              cityID: 13,
                                              injector: MockSCInjector(),
                                              dataCache: dataCache ?? SCDataCacheMock(),
                                              citizenSurveyWorker: SCCitizenSurveyWorker(requestFactory: SCRequestMock()))
    }
    
    private func mockSurveyDescription(description: NSAttributedString) -> NSAttributedString {
        var surveyDescription = NSMutableAttributedString(attributedString: description)
        surveyDescription.addAttributes([.foregroundColor: UIColor(named: "CLR_LABEL_TEXT_BLACK")!],
                                  range: NSRange(0..<surveyDescription.length))
        return surveyDescription
    }
    
    func testGetSurveyPresentableStartDate() {
        let mockStartDate = String(format: LocalizationKeys.SCCitizenSurveyDetailPresenter.cs003CreationDateFormat.localized().replaceStringFormatter(),
                                   stringFromDate(date: Date()))
        let sut = prepareSut()
        XCTAssertEqual(sut.getSurveyPresentableStartDate(), mockStartDate)
    }
    
    func testGetSurveyImage() {
        let mockImage = SCImageURL(urlString: "test/image", persistence: false)
        let sut = prepareSut()
        XCTAssertEqual(sut.getSurveyImage(), mockImage)
    }
    
    func testGetSurveyEndDatePlaceholder() {
        let mockPlaceHolder = LocalizationKeys.SCCitizenSurveyDetailPresenter.cs003EndDateLabel.localized()
        let sut = prepareSut()
        XCTAssertEqual(sut.getSurveyEndDatePlaceholder(), mockPlaceHolder)
    }
    
    func testGetSurveyPresentableEndDate() {
        let mockEndDate = stringFromDate(date: Date())
        let sut = prepareSut()
        XCTAssertEqual(sut.getSurveyPresentableEndDate(), mockEndDate)
    }
    
    func testGetSurveyTitle() {
        let mockSurveyTitle = "TestSurvey"
        let sut = prepareSut()
        XCTAssertEqual(sut.getSurveyTitle(), mockSurveyTitle)
    }
    
    func testGetSurveyStatus() {
        let mockStatus = SCSurveyStatus.inProgress
        let sut = prepareSut()
        XCTAssertEqual(sut.getSurveyStatus(), mockStatus)
    }

    func testGetSurveyIsPopular() {
        let sut = prepareSut()
        XCTAssertTrue(sut.getSurveyIsPopular())
    }
    
    func testGetSurveyHeading() {
        let mockSurveyTitle = "TestSurvey"
        let sut = prepareSut()
        XCTAssertEqual(sut.getSurveyHeading(), mockSurveyTitle)
    }
    
    func testGetSurveyDescription() {
        let surveyDescription = "TestSurveyDescription"
        let sut = prepareSut()
        XCTAssertEqual(sut.getSurveyDescription(),
                       mockSurveyDescription(description: surveyDescription.htmlAttributedString ?? NSAttributedString(string: "")))
    }
    
    func testDisplaySurveyQuestionViewControllerWithNoError() {
        let successResponseData = JsonReader().readJsonFrom(fileName: "SurveyDetails",
                                                            withExtension: "json")
        let mockWorker = SCCitizenSingleSurveyWorker(requestFactory: SCRequestMock(successResponse: successResponseData))
        let sut = prepareSut(singleSurveyWorker: mockWorker)
        let displayer = SCCitizenSurveyDetailDisplayer()
        display = displayer
        sut.set(display: displayer)
        sut.displaySurveyQuestionViewController()
        XCTAssertTrue(displayer.isShowActivityIndicatorCalled)
        let exp = expectation(description: "Test after 3 seconds")
         let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
         if result == XCTWaiter.Result.timedOut {
             XCTAssertTrue(displayer.isPushCalled)
         } else {
             XCTFail("Delay interrupted")
         }
    }
    
    func testDisplaySurveyQuestionViewControllerWithError() {
        let mockedError = SCRequestError.noInternet
        let mockWorker = SCCitizenSingleSurveyWorker(requestFactory: SCRequestMock(errorResponse: mockedError))
        let sut = prepareSut(singleSurveyWorker: mockWorker)
        let displayer = SCCitizenSurveyDetailDisplayer()
        display = displayer
        sut.set(display: displayer)
        sut.displaySurveyQuestionViewController()
        XCTAssertTrue(displayer.isShowActivityIndicatorCalled)
        let exp = expectation(description: "Test after 3 seconds")
         let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
         if result == XCTWaiter.Result.timedOut {
             XCTAssertFalse(displayer.isPushCalled)
         } else {
             XCTFail("Delay interrupted")
         }
    }
    
    func testDisplayDataPrivacyViewControllerWhenAccepted() {
        let dataCache = SCDataCacheMock()
//        dataCache.setDataPrivacyAccepted(for: 12, cityID: "13")
        
        let successResponseData = """
        {
            "content": [{
                "dpn_text": "<p>Citykey does not collect or request any personal or personally identifiable information in the following survey. The City of Siegburg is responsible for the content of the survey. The results will be made available to the city of Siegburg by Citykey after completion of the survey and subsequently deleted in Citykey. The evaluation of the results is carried out by the city.</p><p><b>Important:</b> Please make sure not to enter any personal or person-related data in free text fields, as this content will also be transferred to the city in plain text.</p>"
            }]
        }
        """
        let mockCitizenSurveyWorker = SCCitizenSurveyWorker(requestFactory: SCRequestMock(successResponse: successResponseData.data(using: .utf8)))
        
        let mockDeleagate = SCCitizenSurveyDetailViewDelegateMock()
        let sut = prepareSut(dataCache: dataCache, surveyWorker: mockCitizenSurveyWorker)
        let displayer = SCCitizenSurveyDetailDisplayer()
        sut.set(display: displayer)
        sut.displayDataPrivacyViewController(delegate: mockDeleagate)
        let exp = expectation(description: "Test after 3 seconds")
         let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
         if result == XCTWaiter.Result.timedOut {
             XCTAssertFalse(displayer.isPushCalled)
         } else {
             XCTFail("Delay interrupted")
         }
    }
    
    
}

extension MockSCInjector: SCCitizenSurveyServiceInjecting {
    func getCitizenSurveyPageViewController(survey: OSCA.SCModelCitizenSurvey) -> UIViewController {
        return UIViewController()
    }
    
    func getCitizenSurveyDetailViewController(survey: OSCA.SCModelCitizenSurveyOverview, serviceData: OSCA.SCBaseComponentItem) -> UIViewController {
        return UIViewController()
    }
    
    func getCitizenSurveyOverViewController(surveyList: [OSCA.SCModelCitizenSurveyOverview], serviceData: OSCA.SCBaseComponentItem) -> UIViewController {
        return UIViewController()
    }
    
    func getCitizenSurveyDataPrivacyViewController(survey: OSCA.SCModelCitizenSurveyOverview, delegate: OSCA.SCCitizenSurveyDetailViewDelegate?, dataPrivacyNotice: OSCA.DataPrivacyNotice) -> UIViewController {
        return UIViewController()
    }
    
    
}

class SCCitizenSurveyDetailDisplayer: SCCitizenSurveyDetailDisplaying {
    
    private(set) var isShowActivityIndicatorCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    private(set) var isShowErrorDialog: Bool = false
    private(set) var isPresentCalled: Bool = false
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func showBtnActivityIndicator(_ show: Bool) {
        isShowActivityIndicatorCalled = true
    }
    
    func present(viewController: UIViewController) {
        isPresentCalled = true
    }
}


extension SCCitizenSurveyDetailDisplayer: SCDisplaying {
    func showErrorDialog(_ error: SCWorkerError, retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil) {
        isShowErrorDialog = true
    }
}
