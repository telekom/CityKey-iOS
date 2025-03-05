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
