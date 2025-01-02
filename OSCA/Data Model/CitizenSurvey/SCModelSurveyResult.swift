//
//  SCModelSurveyResult.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 30/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelSurveyResult: Encodable {
      var totalQuestions: Int
      var attemptedQuestions: Int
      var responses: [SCModelSurveyQuestionResult]
}

struct SCModelSurveyQuestionResult: Encodable {
    var questionId: Int
    var topicId: Int
    var optionNo: Int
    var freeText: String
}
