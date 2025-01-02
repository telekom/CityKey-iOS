//
//  SCCitizenServeyDefinitions.swift
//  OSCA
//
//  Created by Michael on 11.12.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

enum SCSurveyStatus: String {

    case finish = "completed"
    case inProgress = "started"
    case toBeStart = "not_started"

    struct SCSurveyViewConfig {
        let isFinished: Bool
        let progressImage: UIImage?
    }

    func getViewConfiguration() -> SCSurveyViewConfig {
        switch self {
        case .toBeStart:
            return SCSurveyViewConfig(isFinished: false,
                                      progressImage: nil)

        case .inProgress:
            return SCSurveyViewConfig(isFinished: false,
                                      progressImage: UIImage(named: "survey-icon-idle"))

        // SMARTC-19418 Client: Design review for citykey App
        case .finish:
            return SCSurveyViewConfig(isFinished: true,
                                      progressImage: UIImage(named: "survey-icon-finished")?.maskWithColor(color: kColor_cityColor))
        }
    }
}
