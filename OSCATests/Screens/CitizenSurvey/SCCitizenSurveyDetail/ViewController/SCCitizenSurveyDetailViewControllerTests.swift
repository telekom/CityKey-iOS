//
//  SCCitizenSurveyDetailViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 19/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
final class SCCitizenSurveyDetailViewControllerTests: XCTestCase {
    private func prepareSut(presenter: SCCitizenSurveyDetailPresenting? = nil) -> SCCitizenSurveyDetailViewController {
        let storyboard = UIStoryboard(name: "CitizenSurvey", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCCitizenSurveyDetailViewController") as! SCCitizenSurveyDetailViewController
        sut.presenter = presenter ?? getMockPresenter()
        sut.loadViewIfNeeded()
        return sut
    }
    
    private func getMockPresenter() -> SCCitizenSurveyDetailPresenting {
        let survey = SCModelCitizenSurveyOverview(isDpAccepted: true, id: 12, name: "TestSurvey", description: "TestSurveyDescription",
                                                  startDate: Date(), endDate: Date(), isPopular: true,
                                                  status: .inProgress, dataProtectionText: "", isClosed: false,
                                                  totalQuestions: 3, attemptedQuestions: 1, daysLeft: 3)
        let serviceData = SCBaseComponentItem(itemID: "", itemTitle: "", itemImageURL: SCImageURL(urlString: "test/image", persistence: false), itemHtmlDetail: false, itemColor: .blue)
        return SCCitizenSurveyDetailPresenterMock(survey: survey, serviceData: serviceData)
    }
    
    func testViewDidLoad() {
        let mockTitle = "TestSurvey"
        let sut = prepareSut()
        sut.viewDidLoad()
        XCTAssertEqual(sut.surveyNameLabel.text, mockTitle)
    }
    
    func testDidTapOnStartSurvey() {
        let survey = SCModelCitizenSurveyOverview(isDpAccepted: true, id: 12, name: "TestSurvey", description: "TestSurveyDescription",
                                                  startDate: Date(), endDate: Date(), isPopular: true,
                                                  status: .inProgress, dataProtectionText: "", isClosed: false,
                                                  totalQuestions: 3, attemptedQuestions: 1, daysLeft: 3)
        let serviceData = SCBaseComponentItem(itemID: "", itemTitle: "", itemImageURL: SCImageURL(urlString: "test/image", persistence: false), itemHtmlDetail: false, itemColor: .blue)
        let presenter = SCCitizenSurveyDetailPresenterMock(survey: survey, serviceData: serviceData)
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        sut.didTapOnStartSurvey(UIButton())
        XCTAssertTrue(presenter.isDisplayDataPrivacyCalled)
    }
}


class SCCitizenSurveyDetailPresenterMock: SCCitizenSurveyDetailPresenting {
    var survey: SCModelCitizenSurveyOverview
    var serviceData: SCBaseComponentItem
    private(set) var isDisplayDataPrivacyCalled: Bool = false
    
    init(survey: SCModelCitizenSurveyOverview, serviceData: SCBaseComponentItem) {
        self.survey = survey
        self.serviceData = serviceData
    }
    func set(display: OSCA.SCCitizenSurveyDetailDisplaying) {
        
    }
    
    func getSurveyImage() -> OSCA.SCImageURL? {
        return serviceData.itemImageURL
    }
    
    func getSurveyPresentableStartDate() -> String {
        String(format: LocalizationKeys.SCCitizenSurveyDetailPresenter.cs003CreationDateFormat.localized().replaceStringFormatter(),
               stringFromDate(date: survey.startDate))
    }
    
    func getSurveyEndDatePlaceholder() -> String {
        return LocalizationKeys.SCCitizenSurveyDetailPresenter.cs003EndDateLabel.localized()
    }
    
    func getSurveyPresentableEndDate() -> String {
        return stringFromDate(date: survey.endDate)
    }
    
    func getSurveyDaysLeftViewProgress() -> (Double, Int) {
        (0.0, 6)
    }
    
    func getSurveyTitle() -> String {
        return survey.name
    }
    
    func getSurveyStatus() -> OSCA.SCSurveyStatus {
        SCSurveyStatus.inProgress
    }
    
    func getSurveyIsPopular() -> Bool {
        return survey.isPopular
    }
    
    func getSurveyHeading() -> String {
        return survey.name
    }
    
    func getSurveyDescription() -> NSAttributedString? {
        return survey.description.htmlAttributedString
    }
    
    func getShareButton() -> UIBarButtonItem {
        UIBarButtonItem()
    }
    
    func displaySurveyQuestionViewController() {
        
    }
    
    func displayDataPrivacyViewController(delegate: OSCA.SCCitizenSurveyDetailViewDelegate) {
        isDisplayDataPrivacyCalled = true
    }
}
