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
//  SCCitizenSurveyQuestionViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 20/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCitizenSurveyQuestionViewControllerTests: XCTestCase {
    private func prepareSut(presenter: SCCitizenSurveyQuestionPresenting? = nil,
    delegate: SCCitizenSurveyPageViewPresenterDelegate? = nil) -> SCCitizenSurveyQuestionViewController {
        let storyboard = UIStoryboard(name: "CitizenSurvey", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCCitizenSurveyQuestionViewController") as! SCCitizenSurveyQuestionViewController
        sut.presenter = presenter ?? SCCitizenSurveyQuestionPresenterMock(surveyQuestion: getMockSurveyQuestions().first!)
        sut.delegate = delegate
        sut.loadViewIfNeeded()
        return sut
    }
    
    func getMockSurveyQuestions() -> [SCModelQuestionSurvey] {
        let successResponseData = JsonReader().readJsonFrom(fileName: "SurveyDetails",
                                                            withExtension: "json")
        let survey = JsonReader().parseJsonData(of: SCHttpModelResponse<SCModelCitizenSurvey>.self,
                                          data: successResponseData)
        return survey?.content.questions ?? []
    }
    
    func testViewDidLoad() {
        let previousBtnTitleMock = LocalizationKeys.SCCitizenSurveyQuestionViewController.cs004ButtonPrevious.localized()
        let presenter = SCCitizenSurveyQuestionPresenterMock(surveyQuestion: getMockSurveyQuestions().first!)
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        XCTAssertEqual(sut.surveyNameLabel.text, presenter.getSurveyTitle())
        XCTAssertEqual(sut.questionLabel.text, presenter.getSurveyQuestionText())
        XCTAssertEqual(sut.questionHintLabel.text, presenter.getSurveyQuestionHint())
        XCTAssertEqual(sut.previousQuestionButton.titleLabel?.text, previousBtnTitleMock)
    }
    
    func testDidTapOnPrevious() {
        let presenter = SCCitizenSurveyQuestionPresenterMock(surveyQuestion: getMockSurveyQuestions().first!)
        let delegate = SCCitizenSurveyPageViewPresenterDelegateMock()
        let sut = prepareSut(presenter: presenter, delegate: delegate)
        sut.questionIndex = 2
        sut.viewDidLoad()
        sut.didTapOnPrevious(UIButton())
        guard let pageViewPresenterDelegate = sut.delegate as? SCCitizenSurveyPageViewPresenterDelegateMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(pageViewPresenterDelegate.isPreviousPageCalled)
    }
    
    func testDidTapOnNextWithNoIndex() {
        let presenter = SCCitizenSurveyQuestionPresenterMock(surveyQuestion: getMockSurveyQuestions().first!)
        let delegate = SCCitizenSurveyPageViewPresenterDelegateMock()
        let sut = prepareSut(presenter: presenter, delegate: delegate)
        sut.questionIndex = 2
        sut.viewDidLoad()
        sut.didTapOnNext(UIButton())
        XCTAssertTrue(presenter.isValidateTextViewCalled)
    }
    
    func testDidTapOnNextWithIndex() {
        let presenter = SCCitizenSurveyQuestionPresenterMock(surveyQuestion: getMockSurveyQuestions().first!)
        presenter.textViewFilled = true
        let delegate = SCCitizenSurveyPageViewPresenterDelegateMock()
        let sut = prepareSut(presenter: presenter, delegate: delegate)
        sut.questionIndex = 2
        sut.viewDidLoad()
        sut.didTapOnNext(UIButton())
        guard let pageViewPresenterDelegate = sut.delegate as? SCCitizenSurveyPageViewPresenterDelegateMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(pageViewPresenterDelegate.isNextPageCalled)
    }
    
    func testUpdateNextButtonEnabled() {
        let presenter = SCCitizenSurveyQuestionPresenterMock(surveyQuestion: getMockSurveyQuestions().first!)
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        sut.updateNextButton(isEnabled: true, alpha: 1)
        XCTAssertTrue(sut.nextQuestionButton.isEnabled)
    }
    
    func testUpdateFinishStateOfNextButtonLastPage() {
        let nextBtnMockTitle = LocalizationKeys.SCCitizenSurveyQuestionViewController.cs004ButtonDone.localized()
        let presenter = SCCitizenSurveyQuestionPresenterMock(surveyQuestion: getMockSurveyQuestions().first!)
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        sut.updateFinishStateOfNextButton(isLastPage: true)
        XCTAssertEqual(sut.nextQuestionButton.titleLabel?.text, nextBtnMockTitle)
    }
    
    func testUpdateFinishStateOfNextButtonWithNotLastPage() {
        let nextBtnMockTitle = LocalizationKeys.SCCitizenSurveyQuestionViewController.cs004ButtonNext.localized()
        let presenter = SCCitizenSurveyQuestionPresenterMock(surveyQuestion: getMockSurveyQuestions().first!)
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        sut.updateFinishStateOfNextButton(isLastPage: false)
        XCTAssertEqual(sut.nextQuestionButton.titleLabel?.text, nextBtnMockTitle)
    }
    
}

final class SCCitizenSurveyQuestionPresenterMock: SCCitizenSurveyQuestionPresenting {
    private(set) var isViewDidLoadCalled: Bool = false
    let survey: SCModelQuestionSurvey
    private(set) var isValidateTextViewCalled: Bool = false
    var textViewFilled: Bool = false
    init(surveyQuestion: SCModelQuestionSurvey) {
        self.survey = surveyQuestion
    }
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func set(display: OSCA.SCCitizenSurveyQuestionDisplaying) {
            
    }
    
    func getSurveyTitle() -> String {
        ""
    }
    
    func getSurveyQuestionText() -> String {
        survey.questionText
    }
    
    func getSurveyQuestionHint() -> String? {
        survey.questionHint
    }
    
    func getQuestionView() -> UIView {
        UIView()
    }
    
    func isTextViewFilled() -> Bool {
        textViewFilled
    }
    
    func validateTextView() {
        isValidateTextViewCalled = true
    }
}

class SCCitizenSurveyPageViewPresenterDelegateMock: SCCitizenSurveyPageViewPresenterDelegate {
    private(set) var isPreviousPageCalled: Bool = false
    private(set) var isNextPageCalled: Bool = false
    func nextPage(index: Int) {
        isNextPageCalled = true
    }
    
    func previousPage(index: Int) {
        isPreviousPageCalled = true
    }
}
