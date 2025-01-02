//
//  SCCitizenSurveyQuestionPresenting.swift
//  OSCA
//
//  Created by Bhaskar N S on 20/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCCitizenSurveyQuestionDisplaying {
    func updateNextButton(isEnabled: Bool, alpha: CGFloat)
    func updateFinishStateOfNextButton(isLastPage: Bool)
}

protocol SCCitizenSurveyQuestionPresenting: SCPresenting {
    func set(display: SCCitizenSurveyQuestionDisplaying)
    func getSurveyTitle() -> String
    func getSurveyQuestionText() -> String
    func getSurveyQuestionHint() -> String?
    func getQuestionView() -> UIView
    func isTextViewFilled() -> Bool
    func validateTextView()
}
