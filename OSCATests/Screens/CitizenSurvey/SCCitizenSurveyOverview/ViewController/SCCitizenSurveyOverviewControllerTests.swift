//
//  SCCitizenSurveyOverviewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 20/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA


final class SCCitizenSurveyOverviewControllerTests: XCTestCase {
    
    private func prepareSut(presenter: SCCitizenSurveyOverviewPresenting? = nil) -> SCCitizenSurveyOverviewController {
        let storyboard = UIStoryboard(name: "CitizenSurvey", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCCitizenSurveyOverviewController") as! SCCitizenSurveyOverviewController
        sut.presenter = presenter ?? SCCitizenSurveyOverviewPresenterMock(surveyOverview: getSurveyOverview())
        sut.loadViewIfNeeded()
        return sut
    }
    
    private func getSurveyOverview() -> SCModelCitizenSurveyOverview {
        SCModelCitizenSurveyOverview(isDpAccepted: true, id: 12, name: "TestSurvey", description: "TestSurveyDescription",
                                                  startDate: Date(), endDate: Date(), isPopular: true,
                                                  status: .inProgress, dataProtectionText: "", isClosed: false,
                                                  totalQuestions: 3, attemptedQuestions: 1, daysLeft: 3)
    }
    
    func testViewDidLoad() {
        let mockNavTitle = LocalizationKeys.SCCitizenSurveyOverviewViewController.cs002PageTitle.localized()
        let presenter = SCCitizenSurveyOverviewPresenterMock(surveyOverview: getSurveyOverview())
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        XCTAssertTrue(presenter.isViewDidLoadCalled)
        XCTAssertEqual(sut.navigationItem.title, mockNavTitle)
    }
    
    func testUpdateSurveyList() {
        let presenter = SCCitizenSurveyOverviewPresenterMock(surveyOverview: getSurveyOverview())
        let sut = prepareSut(presenter: presenter)
        sut.updateSurveyList()
        XCTAssertTrue(presenter.isFetchCalled)
    }
    
    func testSelected() {
        let presenter = SCCitizenSurveyOverviewPresenterMock(surveyOverview: getSurveyOverview())
        let sut = prepareSut(presenter: presenter)
        sut.selected(survey: getSurveyOverview())
        XCTAssertTrue(presenter.displaySurveyDetailsCalled)
    }
    
    
}

final class SCCitizenSurveyOverviewPresenterMock: SCCitizenSurveyOverviewPresenting {
    let surveyOverview: SCModelCitizenSurveyOverview
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var isFetchCalled: Bool = false
    private(set) var displaySurveyDetailsCalled: Bool = false
    init(surveyOverview: SCModelCitizenSurveyOverview) {
        self.surveyOverview = surveyOverview
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
        
    }
    
    func set(display: OSCA.SCCitizenSurveyOverviewDisplaying) {
        
    }
    
    func getSurveyList() -> [OSCA.SCModelCitizenSurveyOverview] {
        [surveyOverview]
    }
    
    func displaySurveyDetails(survey: OSCA.SCModelCitizenSurveyOverview) {
        displaySurveyDetailsCalled = true
    }
    
    func fetchSurveyList() {
        isFetchCalled = true
    }
}
