//
//  SCModelCitizenSurvey.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 01/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class SCModelCitizenSurvey: Decodable, Equatable {
    static func == (lhs: SCModelCitizenSurvey, rhs: SCModelCitizenSurvey) -> Bool {
        return lhs.surveyId == rhs.surveyId &&
        lhs.userId == rhs.userId &&
        lhs.surveyName == rhs.surveyName &&
        lhs.totalQuestions == rhs.totalQuestions &&
        lhs.attemptedQuestions == rhs.attemptedQuestions &&
        lhs.questions == rhs.questions
    }
    
    var surveyId: Int?
    var userId: Int?
    var surveyName: String?
    let totalQuestions: Int
    let attemptedQuestions: Int
    var questions: [SCModelQuestionSurvey]
}

class SCModelQuestionSurvey: Decodable, Equatable {
    static func == (lhs: SCModelQuestionSurvey, rhs: SCModelQuestionSurvey) -> Bool {
        return lhs.questionId == rhs.questionId &&
        lhs.questionAnswered == rhs.questionAnswered &&
        lhs.questionOrder == rhs.questionOrder &&
        lhs.questionText == rhs.questionText &&
        lhs.questionHint == rhs.questionHint &&
        lhs.topics == rhs.topics
    }
    
    var questionId: Int
    var questionAnswered: Bool
    var questionOrder: Int
    var questionText: String
    var questionHint: String?
    var topics: [SCModelQuestionTopic]
}

class SCModelQuestionTopic: Decodable, Equatable {
    static func == (lhs: SCModelQuestionTopic, rhs: SCModelQuestionTopic) -> Bool {
        return lhs.topicId == rhs.topicId &&
        lhs.topicId == rhs.topicId &&
        lhs.topicId == rhs.topicId &&
        lhs.topicName == rhs.topicName &&
        lhs.topicDesignType == rhs.topicDesignType &&
        lhs.topicOrder == rhs.topicOrder
    }
    
    var topicId: Int
    var topicName: String

    //1: Unframed topic, 2: Framed topic
    var topicDesignType: Int?
    var topicOrder: Int

    //"RB" OR "CB"
    var topicOptionType: String
    var options: [SCModelQuestionTopicOption]

    var topicDesign: SCTopicDesignType {
        if topicDesignType == 1 {
            return .unframed
        } else if topicDesignType == 2 {
            return .framed
        }
        return .none
    }

    var topicAnswerType: SCTopicAnswerType {
        if topicOptionType == "CB" {
            return .multiple
        } else if topicOptionType == "RB" {
            return .single
        } else if topicOptionType == "OQ" {
            return .descriptive
        }
        return .none
    }
}

class SCModelQuestionTopicOption: Decodable, Equatable {
    static func == (lhs: SCModelQuestionTopicOption, rhs: SCModelQuestionTopicOption) -> Bool {
        return lhs.optionNo == rhs.optionNo &&
        lhs.optionText == rhs.optionText &&
        lhs.optionSelected == rhs.optionSelected &&
        lhs.textAreaMandatory == rhs.textAreaMandatory &&
        lhs.hasTextArea == rhs.hasTextArea &&
        lhs.textAreaDescription == rhs.textAreaDescription &&
        lhs.textAreaInput == rhs.textAreaInput
    }
    
    var optionNo: Int?
    var optionText: String?
    var optionSelected: Bool?
    var textAreaMandatory: Bool?
    var hasTextArea: Bool?
    var textAreaDescription: String?
    var textAreaInput: String?
    
    enum CodingKeys: String, CodingKey {
        case optionNo, optionText, optionSelected, textAreaMandatory, hasTextArea, textAreaDescription, textAreaInput
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.optionNo = try container.decodeIfPresent(Int.self, forKey: .optionNo)
        self.optionText = try container.decodeIfPresent(String.self, forKey: .optionText)
        self.optionSelected = try container.decodeIfPresent(BoolOrInt.self, forKey: .optionSelected)?.value
        self.textAreaMandatory = try container.decodeIfPresent(BoolOrInt.self, forKey: .textAreaMandatory)?.value
        self.hasTextArea = try container.decodeIfPresent(BoolOrInt.self, forKey: .hasTextArea)?.value
        self.textAreaDescription = try container.decodeIfPresent(String.self, forKey: .textAreaDescription)
        self.textAreaInput = try container.decodeIfPresent(String.self, forKey: .textAreaInput)
    }
}

struct BoolOrInt: Decodable {
    var value: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self.value = (intValue != 0)
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else {
            throw DecodingError.typeMismatch(Bool.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected Bool or Int"))
        }
    }
}

enum SCTopicDesignType {
    case framed
    case unframed
    case none
}

enum SCTopicAnswerType {
    case single
    case multiple
    case descriptive
    case none
}




