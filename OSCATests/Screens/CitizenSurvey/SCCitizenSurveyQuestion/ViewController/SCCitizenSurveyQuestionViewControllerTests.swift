//
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
