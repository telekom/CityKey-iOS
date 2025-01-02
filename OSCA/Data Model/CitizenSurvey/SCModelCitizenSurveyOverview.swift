//
//  SCModelCitizenSurveyOverview.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 09/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCHttpModelCitizenSurveyOverview: Decodable, Equatable {
    let isDpAccepted: Bool?
    let id: Int?
    let name: String?
    let description: String?
    let startDate: String?
    let endDate: String?
    let isPopular: Bool?
    let status: String?
    let dataProtectionText: String?
    let isClosed: Bool?
    let totalQuestions: Int
    let attemptedQuestions: Int?
    let daysLeft: Int?

    func toModel() -> SCModelCitizenSurveyOverview {

        let surveyStatus = (SCSurveyStatus(rawValue: status?.lowercased() ?? "") ?? .toBeStart)
        return SCModelCitizenSurveyOverview(isDpAccepted: isDpAccepted ?? false,
                                            id: id ?? -1,
                                            name: name ?? "",
                                            description: description ?? "",
                                            startDate: dateFromString(dateString: startDate ?? "") ?? Date(),
                                            endDate: dateFromString(dateString: endDate ?? "") ?? Date(),
                                            isPopular: isPopular ?? false,
                                            status: surveyStatus,
                                            dataProtectionText: dataProtectionText ?? "",
                                            isClosed: isClosed ?? false,
                                            totalQuestions: totalQuestions,
                                            attemptedQuestions: attemptedQuestions ?? 0,
                                            daysLeft: daysLeft ?? 0)
    }
    
    static func == (lhs: SCHttpModelCitizenSurveyOverview, rhs: SCHttpModelCitizenSurveyOverview) -> Bool {
        return lhs.id == rhs.id &&
        lhs.isDpAccepted == rhs.isDpAccepted &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.isPopular == rhs.isPopular &&
        lhs.status == rhs.status &&
        lhs.dataProtectionText == rhs.dataProtectionText &&
        lhs.isClosed == rhs.isClosed &&
        lhs.totalQuestions == rhs.totalQuestions &&
        lhs.attemptedQuestions == rhs.attemptedQuestions &&
        lhs.daysLeft == rhs.daysLeft
    }
}

struct SCModelCitizenSurveyOverview: Equatable {
    
    static func ==(lhs: SCModelCitizenSurveyOverview, rhs: SCModelCitizenSurveyOverview) -> Bool {
        return lhs.isDpAccepted == rhs.isDpAccepted &&
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.isPopular == rhs.isPopular &&
        lhs.status == rhs.status &&
        lhs.dataProtectionText == rhs.dataProtectionText &&
        lhs.isClosed == rhs.isClosed &&
        lhs.totalQuestions == rhs.totalQuestions &&
        lhs.attemptedQuestions == rhs.attemptedQuestions &&
        lhs.daysLeft == rhs.daysLeft
    }

    let isDpAccepted: Bool
    let id: Int
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    let isPopular: Bool
    let status: SCSurveyStatus
    let dataProtectionText: String
    let isClosed: Bool
    let totalQuestions: Int
    let attemptedQuestions: Int
    let daysLeft: Int

    func getDaysLeftProgress() -> Double {

        if Date().difference(from: startDate) > 0 {
            return 0.0
        }

        if daysLeft == 0 {
            return 1.0
        }

        let maxDays = endDate.days(from: startDate)

        if maxDays == 0 {
            return 1.0
        }

        return 1.0 - (Double(daysLeft) / Double(maxDays))
    }
}

// MARK: - DataPrivacyNotice
struct DataPrivacyNotice: Codable, Equatable {
    let content: [Content]?
}

// MARK: - Content
struct Content: Codable, Equatable {
    let dpnText: String?

    enum CodingKeys: String, CodingKey {
        case dpnText = "dpn_text"
    }
}

