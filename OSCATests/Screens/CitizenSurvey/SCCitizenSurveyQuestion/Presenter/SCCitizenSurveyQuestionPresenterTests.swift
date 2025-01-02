//
//  SCCitizenSurveyQuestionPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 20/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCitizenSurveyQuestionPresenterTests: XCTestCase {
    var display: SCCitizenSurveyQuestionDisplaying?
    
    private func prepareSut(surveyQuestion: SCModelQuestionSurvey, surveyTitle: String, lastPage: Bool) -> SCCitizenSurveyQuestionPresenter {
        return SCCitizenSurveyQuestionPresenter(surveyQuestion: surveyQuestion, surveyTitle: surveyTitle, lastPage: lastPage)
    }
    
    func getMockSurveyQuestions() -> [SCModelQuestionSurvey] {
        let successResponseData = JsonReader().readJsonFrom(fileName: "SurveyDetails",
                                                            withExtension: "json")
        let survey = JsonReader().parseJsonData(of: SCHttpModelResponse<SCModelCitizenSurvey>.self,
                                          data: successResponseData)
        return survey?.content.questions ?? []
    }
    
    func testViewDidLoad() {
        let surveyQuestion = getMockSurveyQuestions()
        let sut = prepareSut(surveyQuestion: getMockSurveyQuestions().first!, surveyTitle: "surveyTitle", lastPage: false)
        let display = SCCitizenSurveyQuestionDisplayer()
        self.display = display
        sut.set(display: display)
        sut.viewDidLoad()
        XCTAssertTrue(display.isUpdateFinishStateOfNextButton)
        
    }
    
    func testGetSurveyTitle() {
        let mockTitle = "surveyTitle"
        let surveyQuestion = getMockSurveyQuestions()
        let sut = prepareSut(surveyQuestion: getMockSurveyQuestions().first!, surveyTitle: mockTitle, lastPage: false)
        let display = SCCitizenSurveyQuestionDisplayer()
        self.display = display
        sut.set(display: display)
        sut.viewDidLoad()
        XCTAssertEqual(sut.getSurveyTitle(), mockTitle)
    }
    
    func testGetSurveyQuestionText() {
        let surveyQuestion = getMockSurveyQuestions().first
        let mockSurveyQuestionText = surveyQuestion?.questionText ?? ""
        let sut = prepareSut(surveyQuestion: getMockSurveyQuestions().first!, surveyTitle: "surveyTitle", lastPage: false)
        let display = SCCitizenSurveyQuestionDisplayer()
        self.display = display
        sut.set(display: display)
        sut.viewDidLoad()
        XCTAssertEqual(sut.getSurveyQuestionText(), mockSurveyQuestionText)
    }
    
    func testGetSurveyQuestionHint() {
        let surveyQuestion = getMockSurveyQuestions().first
        let mockSurveyQuestionHint = surveyQuestion?.questionHint ?? ""
        let sut = prepareSut(surveyQuestion: getMockSurveyQuestions().first!, surveyTitle: "surveyTitle", lastPage: false)
        let display = SCCitizenSurveyQuestionDisplayer()
        self.display = display
        sut.set(display: display)
        sut.viewDidLoad()
        XCTAssertEqual(sut.getSurveyQuestionHint(), mockSurveyQuestionHint)
    }
    
    func testIsTextViewFilled() {
        let surveyQuestion = getMockSurveyQuestions()
        let sut = prepareSut(surveyQuestion: getMockSurveyQuestions().first!, surveyTitle: "surveyTitle", lastPage: false)
        let display = SCCitizenSurveyQuestionDisplayer()
        self.display = display
        sut.set(display: display)
        sut.viewDidLoad()
        XCTAssertTrue(sut.isTextViewFilled())
    }

}

class SCCitizenSurveyQuestionDisplayer: SCCitizenSurveyQuestionDisplaying {
    private(set) var isUpdateNextButtonCalled: Bool = false
    private(set) var isUpdateFinishStateOfNextButton: Bool = false
    func updateNextButton(isEnabled: Bool, alpha: CGFloat) {
        isUpdateNextButtonCalled = true
    }
    
    func updateFinishStateOfNextButton(isLastPage: Bool) {
        isUpdateFinishStateOfNextButton = true
    }
    
    
}
