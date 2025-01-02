//
//  SCCitizenSurveyPresenter.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 24/11/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCCitizenSurveyQuestionPresenter {

    var surveyQuestion: SCModelQuestionSurvey
    var surveyTitle: String
    private var questionViewHandler: SCQuestionViewHandler!
    private var display: SCCitizenSurveyQuestionDisplaying?
    let lastPage: Bool
    
    init(surveyQuestion: SCModelQuestionSurvey,
         surveyTitle: String,
         lastPage: Bool) {
        self.surveyQuestion = surveyQuestion
        self.surveyTitle = surveyTitle
        self.lastPage = lastPage
        
        initQuestionViewHandler()
    }

    func initQuestionViewHandler() {
        questionViewHandler = SCQuestionViewHandler(topics: surveyQuestion.topics, delegate: self)
    }

    private func updateNextButton() {
        let answeredTopics = surveyQuestion.topics.filter { (topic) -> Bool in
            return topic.options.contains { (option) -> Bool in
                option.optionSelected ?? false
            }
        }

        if isPreviewMode && lastPage {
            display?.updateNextButton(isEnabled: false, alpha: 0.5)
        } else {
            if answeredTopics.count == surveyQuestion.topics.count {
                // All topics are answered
                display?.updateNextButton(isEnabled: true, alpha: 1.0)
            } else {
                display?.updateNextButton(isEnabled: false, alpha: 0.5)
            }
        }
    }
}

extension SCCitizenSurveyQuestionPresenter: SCCitizenSurveyQuestionPresenting {

    func viewDidLoad() {
        self.display?.updateFinishStateOfNextButton(isLastPage: lastPage)
        updateNextButton()
    }

    func set(display: SCCitizenSurveyQuestionDisplaying) {
        self.display = display
    }

    func getSurveyTitle() -> String {
        return surveyTitle
    }
    
    func getQuestionView() -> UIView {
        questionViewHandler.provideView()
    }

    func getSurveyQuestionText() -> String {
        return surveyQuestion.questionText
    }

    func getSurveyQuestionHint() -> String? {
        return surveyQuestion.questionHint
    }

    func isTextViewFilled() -> Bool {
        var selectedAns : [Bool] = []
        _ = surveyQuestion.topics.filter { (topic) -> Bool in
            return topic.options.contains { (option) -> Bool in
                if option.optionSelected ?? false {
                    if option.textAreaMandatory ?? false {
                        selectedAns.append(option.textAreaInput != "")
                    } else {
                        selectedAns.append(true)
                    }
                }
                return false
            }
        }
        return selectedAns.contains(false) ? false : true
    }

    func validateTextView() {
        questionViewHandler.validateTextView()
    }
}

extension SCCitizenSurveyQuestionPresenter: SCQuestionViewHandlerResultDelegate {

    func update(_ topics: [SCModelQuestionTopic]) {
        surveyQuestion.topics = topics
        updateNextButton()
    }
}
